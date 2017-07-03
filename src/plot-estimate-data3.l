#!/usr/bin/env roseus

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")
(load "~/prog/euslib/jsk/gnuplotlib.l")


(defun callback-point (msg)
  (setq *point-msg* msg)
  )

(defun callback-c-point (msg)
  (setq *c-point-msg* msg)
  )

(defun plot-estimate-data ()
  (ros::roseus "plot_estimate_data")

  (ros::subscribe "/hit_point"
                  geometry_msgs::PointStamped
                  #'callback-point 1)

  (ros::subscribe "/correct_data6"
                  geometry_msgs::Point
                  #'callback-c-point 1)

  (let (t-list x-list y-list cx-list cy-list)

    (setq t-list (list ))
    (setq x-list (list ))
    (setq y-list (list ))
    (setq cx-list (list ))
    (setq cy-list (list ))

    (setq cor-coords nil)

    (setq count 0)

    (while (ros::ok)

      (setq *point-msg* nil)
      (setq *c-point-msg* nil)
      (ros::spin-once)

      (when (and *c-point-msg* (not cor-coords))
        (print "receive correct msg")
        (setq cor-coords *c-point-msg*))

      (when (and *point-msg* cor-coords)
        (print "receive message")
        (setq est-coords *point-msg*)

        (setq tim (send (send (send est-coords :header) :stamp) :to-sec))

        (when (> count 200)
          (return nil))

        (setq x (send est-coords :point :x))
        (setq y (send est-coords :point :y))

        (setq cx (* (send cor-coords :x) 0.001))
        (setq cy (* (send cor-coords :y) 0.001))

        (push tim t-list)
        (push x x-list)
        (push y y-list)

        (push cx cx-list)
        (push cy cy-list)

        (setq count (+ count 1))
        (setq est-coords nil)

        (format t "estimate-x=~A  correct-x=~A~%" x cx)
        (format t "estimate-y=~A  correct-y=~A~%" y cy)
        )
      )

    (setq t-list (mapcar #'(lambda (tm) (- tm (car t-list)))
                         (nreverse t-list)))
    (graph-view
     (list (reverse x-list)
           (reverse y-list)
           (reverse cx-list)
           (reverse cy-list)
           )
     t-list
     :keylist (list "x-list"
                    "y-list"
                    "cx-list"
                    "cy-list"
                    ))

    (print "write graph")
    )
  )

(plot-estimate-data)
