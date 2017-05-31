#!/usr/bin/env roseus

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")
(load "math.l")

(setq *z-param* 100)

(defun callback-coordinate (msg)
  (setq *coordinate-msg* msg)
  )

(defun orbit-estimate ()
  (ros::roseus "orbit-estimate")
  (ros::advertise "hit_point"
                  geometry_msgs::PointStamped)

  (ros::subscribe "/centroid_calc_from_stereo_image"
                  geometry_msgs::PointStamped
                  #'callback-coordinate 1)

  (let (x-list y-list z-list z-x-list coordinate tmp uv header)

    (setq x-list (list ))
    (setq y-list (list ))
    (setq z-list (list ))

    (while (ros::ok)

      (setq *coordinate-msg* nil)
      (ros::spin-once)

      (when *coordinate-msg*
        (setq coordinate *coordinate-msg*)

        (when (> (send coordinate :point :z) *z-param*)
          (push (send coordinate :point :x) x-list)
          (push (send coordinate :point :y) y-list)
          (push (send coordinate :point :z) z-list)
          (setq header (send coordinate :header))
          )

        (print ";; msg received~%")
        (print (length x-list))

        (when (> (length x-list) 7)

          (when (> (length x-list) 10)
            (setq tmp (reverse x-list))
            (pop tmp)
            (setq x-list (reverse tmp))
            (setq tmp (reverse y-list))
            (pop tmp)
            (setq y-list (reverse tmp))
            (setq tmp (reverse z-list))
            (pop tmp)
            (setq z-list (reverse tmp))
            )

          (setq z-x_regressionline (regressionline z-list x-list))
          (setq est-x (+ (* (car z-x_regressionline) *z-param*) (cadr z-x_regressionline)))

          (print "estimate-x")
          (print est-x)

          (setq st-x (cadr z-x_regressionline))
          (setq st-z 0)
          (setq uv (list 0.0 0.0))
          (setf (elt uv 0) (sqrt (/ 1 (+ 1 (* (car z-x_regressionline) (car z-x_regressionline))))))
          (setf (elt uv 1) (sqrt (- 1 (* (elt uv 0) (elt uv 0)))))

          (print "uv")
          (print uv)

          (setq z-x-list (list ))
          (dotimes (i (length x-list))
            (push 0.0 z-x-list))

          (dotimes (i (length x-list))
            (setf (elt z-x-list i) (+ (* (- (elt z-list i) st-z) (elt uv 0)) (* (- (elt x-list i) st-x) (elt uv 1)))))

          (setq meet_zx (+ (* (- *z-param* st-z) (elt uv 0)) (* (- est-x st-x) (elt uv 1))))

          (setq y_quadreg (quadratic_regression z-x-list y-list))
          (setq est-y (+ (+ (* (car y_quadreg) (* meet_zx meet_zx)) (* (cadr y_quadreg) meet_zx)) (caddr y_quadreg)))

          (print "estimate-y")
          (print est-y)

          (setq msg (instance geometry_msgs::PointStamped :init
                              :header header
                              :point
                              (instance geometry_msgs::Point :init
                                        :x est-x
                                        :y est-y
                                        :z *z-param*)))
          (ros::publish "hit_point" msg)

          (setq *coordinate-msg* nil)
          )
        )
      (unix::usleep (* 1000 10));; 10ms
      )
    )
  )

(warn "(orbit-estimate)~%")
(orbit-estimate)
