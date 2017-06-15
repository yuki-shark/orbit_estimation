#!/usr/bin/env roseus

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")
(load "~/prog/euslib/jsk/gnuplotlib.l")


(defun callback-point (msg)
  (setq *point-msg* msg)
  )

(defun plot-test-coordinate-data ()
  (ros::roseus "plot_test_coordinate_data")

  (ros::subscribe "/centroid_calc_from_stereo_image"
                  geometry_msgs::PointStamped
                  #'callback-point 1)

  (let (t-list x-list y-list z-list)

    (setq t-list (list ))
    (setq x-list (list ))
    (setq y-list (list ))
    (setq z-list (list ))

    (setq count 0)
    (setq z0 100000.0)

    ;(setq b-time (send (ros::time-now) :to-sec))

    (while (ros::ok)

      (setq *point-msg* nil)
      ;;(setq b-time nil)
      (ros::spin-once)

      (when *point-msg*
        (print "receive message")
        (setq coordinate *point-msg*)

        (setq time (send (ros::time-now) :to-sec))

        (setq x (send *point-msg* :point :x))
        (setq y (send *point-msg* :point :y))
        (setq z (send *point-msg* :point :z))

        (when (and (> (length x-list) 10) (> z z0))
            (return))

        (when (> z z0)
          (setq count 1))

        (when (eq count 1)

          (push time t-list)
          (push x x-list)
          (push y y-list)
          (push z z-list)

          ;(setq count (+ count 1))
          (setq *point-msg* nil)
          (print x)
          (print y)
          (print z)

          )

        (setq z0 z)

        )
      )

    (setq t-list (mapcar #'(lambda (tm) (- tm (car t-list)))
                         (nreverse t-list)))
    (graph-view
     (list (reverse x-list)
           (reverse y-list)
           (reverse z-list)
           )
     t-list
     :keylist (list "x-list"
                    "y-list"
                    "z-list"))

    (print "write graph")
    )
  )

(plot-test-coordinate-data)
