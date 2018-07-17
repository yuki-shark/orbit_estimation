#!/usr/bin/env roseus

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")
(load "~/prog/euslib/jsk/gnuplotlib.l")


(defun callback-point (msg)
  (setq *point-msg* msg)
  )

(defun plot-estimate-data ()
  (ros::roseus "plot_estimate_data")

  (ros::subscribe "/hit_point"
                  geometry_msgs::PointStamped
                  #'callback-point 1)

  (let (t-list x-list y-list )

    (setq t-list (list ))
    (setq x-list (list ))
    (setq y-list (list ))

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

        (setq x (* 1000 (send *point-msg* :point :x)))
        (setq y (* 1000 (send *point-msg* :point :y)))

        (push time t-list)
        (push x x-list)
        (push y y-list)

        (setq count (+ count 1))
        (setq *point-msg* nil)
        (print x)
        (print y)
        (setq b-time time)

        )

      )
    (setq t-list (mapcar #'(lambda (tm) (- tm (car t-list)))
                         (nreverse t-list)))
    (graph-view
     (list (reverse y-list)
           ;;(reverse y-list)
           )
     t-list
     :keylist (list "y"
                    ;;"y-list"
                    )
     ;;:dump-graph "est_x.eps"
     :dump-graph t
     )

    ;; (graph-view
    ;;  (list ;;(reverse x-list)
    ;;        (reverse y-list)
    ;;        )
    ;;  t-list
    ;;  :keylist (list ;;"x-list"
    ;;                 "y"
    ;;                 )
    ;;  :dump-graph "est_y.eps"
    ;;  :dump-graph t)

    (print "write graph")
    )
  )

(plot-estimate-data)
