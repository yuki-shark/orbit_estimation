#!/usr/bin/env roseus

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")
(load "~/prog/euslib/jsk/gnuplotlib.l")


(defun callback-point (msg)
  (setq *point-msg* msg)
  )

(defun plot-estiamte-data ()
  (ros::roseus "plot_estimate_data")

  (ros::subscribe "/hit_point"
                  geometry_msgs::Point
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

        ;; (when (eq count 0)
        ;;   (setq st time))
        ;; (when (and (not (eq count 0)) ( st time))
        ;;   (return nil))

        ;;(setq time (+ (* 1.0 (send (elt time 0))) (* 0.000000001 (send time 1))))
        (setq x (send *point-msg* :x))
        (setq y (send *point-msg* :y))

        (push time t-list)
        (push x x-list)
        (push y y-list)

        (setq count (+ count 1))
        (setq *point-msg* nil)
        (print x)
        (print y)
        (setq b-time time)

        )

      ;; (when (= st (send (ros::time-now) :to-sec))
      ;;   (return nil)
      ;;   )
      )
    (setq t-list (mapcar #'(lambda (tm) (- tm (car t-list)))
                         (nreverse t-list)))
    (graph-view
     (list (reverse x-list)
           (reverse y-list)
           )
     t-list
     :keylist (list "x-list"
                    "y-list"))

    (print "write graph")
    )
  )

(plot-estiamte-data)
