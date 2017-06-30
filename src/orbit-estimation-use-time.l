#!/usr/bin/env roseus

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")
(load "math.l")

(setq *z-param* 1000)
;;(setq *t-param* 1)

(setq *min-length* 5)
(setq *max-length* 10)

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

  (let (x-list y-list z-list t-list st st-list z-t_regressionline t-x_regressionline coordinate tmp header time_stamp est-x est-y est-t)

    (setq x-list (list ))
    (setq y-list (list ))
    (setq z-list (list ))
    (setq t-list (list ))

    (setq est-t-list (list ))

    (while (ros::ok)

      (setq *coordinate-msg* nil)
      (ros::spin-once)

      (when *coordinate-msg*
        (setq coordinate *coordinate-msg*)

        (when (> (send coordinate :point :z) *z-param*)
          (push (send coordinate :point :x) x-list)
          (push (send coordinate :point :y) y-list)
          (push (send coordinate :point :z) z-list)
          (setq time_stamp (send coordinate :header :stamp))
          (push (send time_stamp :to-sec) t-list)
          (setq header (send coordinate :header))
          )

        (print ";; msg received~%")
        (format t "z: ~A~%" (car z-list))
        (print (length x-list))

        ;;set min length
        (when (>= (length x-list) *min-length*)

          ;;set max length
          (when (> (length x-list) *max-length*)
            (setq tmp (reverse x-list))
            (pop tmp)
            (setq x-list (reverse tmp))
            (setq tmp (reverse y-list))
            (pop tmp)
            (setq y-list (reverse tmp))
            (setq tmp (reverse z-list))
            (pop tmp)
            (setq z-list (reverse tmp))
            (setq tmp (reverse t-list))
            (pop tmp)
            (setq t-list (reverse tmp))
            )

          (when (> (car z-list) (nth (- (length z-list) 1) z-list))
            (setq x-list (list ))
            (setq y-list (list ))
            (setq z-list (list ))
            (setq t-list (list ))
            )

          (when t-list

            (print x-list)
            (print y-list)
            (print z-list)
            (setq st (nth (- (length t-list) 1) t-list))
            ;;(print st)
            ;;absolute time -> relative time
            (setq st-list (mapcar #'(lambda (x) (- x st)) t-list))
            (print st-list)

            (setq z-t_regressionline (regressionline z-list st-list))
            (setq est-t (+ (* (car z-t_regressionline) *z-param*) (cadr z-t_regressionline)))

            (print "estimate-t")
            (print est-t)
            (push est-t est-t-list)
            (print (reverse est-t-list))

            (setq t-x_regressionline (regressionline st-list x-list))
            (setq est-x (+ (* (car t-x_regressionline) est-t) (cadr t-x_regressionline)))

            (print "estimate-x")
            (print est-x)

            (setq y_quadreg (quadratic_regression st-list y-list))
            (setq est-y (+ (+ (* (car y_quadreg) (expt est-t 2)) (* (cadr y_quadreg) est-t)) (caddr y_quadreg)))

            (print "estimate-y")
            (print est-y)
            )

          (setq check nil)
          (when (> (length est-t-list) 3)
            (setq tmp (reverse est-t-list))
            (pop tmp)
            (setq est-t-list (reverse tmp)))
          (when (> (length est-t-list) 2)
            (setq check t)
            (dotimes (i 2)
              (when (> (nth i est-t-list) (nth (+ i 1) est-t-list))
                (setq check nil))))

          (when (and est-x est-y check)
            (setq msg (instance geometry_msgs::PointStamped :init
                                :header header
                                :point
                                (ros::pos->tf-point
                                 (float-vector est-x est-y *z-param*))))

            (ros::publish "hit_point" msg))

          (setq *coordinate-msg* nil)
          )
        )
      (unix::usleep (* 1000 10));; 10ms
      )
    )
  )

(warn "(orbit-estimate)~%")
(orbit-estimate)
