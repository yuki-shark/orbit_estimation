#!/usr/bin/env roseus

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")
(load "~/prog/euslib/jsk/gnuplotlib.l")


(defun callback-point (msg)
  (setq *point-msg* msg)
  )

(defun plot-coordinate-data2 ()
  (ros::roseus "plot_coordinate_data2")

  (ros::subscribe "/centroid_calc_from_stereo_image"
                  geometry_msgs::PointStamped
                  #'callback-point 1)

  (let (t-list x-list y-list z-list)

    (setq t-list (list ))
    (setq x-list (list ))
    (setq y-list (list ))
    (setq z-list (list ))

    (setq count 0)
    (setq b-time (send (ros::time-now) :to-sec))

    (while (ros::ok)

      (setq *point-msg* nil)
      ;;(setq b-time nil)
      (ros::spin-once)

      (when *point-msg*
        (print "receive message")
        (setq coordinate *point-msg*)

        (setq time (send (ros::time-now) :to-sec))

        (when (> b-time time)
          (return nil))

        (setq x (send *point-msg* :point :x))
        (setq y (send *point-msg* :point :y))
        (setq z (send *point-msg* :point :z))

        (push time t-list)
        (push x x-list)
        (push y y-list)
        (push z z-list)

        (setq count (+ count 1))
        (setq *point-msg* nil)
        (print x)
        (print y)
        (print z)
        (setq b-time time)

        )

      )
    (setq t-list (mapcar #'(lambda (tm) (- tm (car t-list)))
                         (nreverse t-list)))
    (graph-view
     (list (reverse x-list))
     t-list
     :keylist (list "x-list"))

    (graph-view
     (list (reverse y-list))
     t-list
     :keylist (list "y-list"))

    (graph-view
     (list (reverse z-list))
     t-list
     :keylist (list "z-list"))

    (print "write graph")
    )
  )

(plot-coordinate-data2)
