#!/usr/bin/env roseus

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")

(setq *z-param* 10)

(defun callback-coordinate (msg)
  (setq *coordinate-msg* msg)
  )

(defun orbit-estimate ()
  (ros::roseus "orbit-estimate")
  (ros::advertise "hit_point"
                  geometry_msgs::Point)

  (ros::subscribe "/centroid_calc_from_stereo_image"
                  geometry_msgs::PointStamped
                  #'callback-coordinate 1)

  (let (x-list y-list z-list coordinate tmp)

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
          )

        (print ";; msg received~%")
        (print (length x-list))

        (when (> (length x-list) 10)

          (when (> (length x-list) 20)
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

          (setq meet_zx (sqrt (+ (* *z-param* *z-param*) (* est-x est-x))))

          (setq z-x-list (listsqrt (listsum (listcross x-list x-list) (listcross z-list z-list))))
          (setq y_quadreg (quadratic_regression z-x-list y-list))
          (setq est-y (+ (+ (* (car y_quadreg) (* meet_zx meet_zx)) (* (cadr y_quadreg) meet_zx)) (caddr u_quadreg)))

          (setq msg (instance geometry_msgs::Point :init
                              :x est-x
                              :y est-y
                              :z *z-param*))
          (ros::publish "hit_point" msg)

          (setq coordinate nil)
          )
        )
      (unix::usleep (* 1000 10));; 10ms
      )
    )
  )

(warn "(orbit-estimate)~%")
(orbit-estimate)
