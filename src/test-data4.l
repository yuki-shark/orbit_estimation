#!/usr/bin/env roseus

;(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")

(defun test_data4 (*x-param* *y-param* *z-param* *radius* *hz*)

  (ros::roseus "test_data4")
  (ros::advertise "centroid_calc_from_stereo_image"
                  geometry_msgs::PointStamped)

  (let (ds theta rad x y z)

    (setq theta 0)
    ;(setq s 0)
    (setq frame (* 1000 (/ 1.0 *hz*)))

    (while (ros::ok)

      (ros::spin-once)

      (setq ds (+ (* 0.9 frame) (random (* 0.2 frame))))
      (setq ds (round ds))
      ;(setq s (+ s ds))

      ;; draw circle
      ;; center: (*x-param* *y-param*)
      ;; radius: *radius*
      (setq theta (mod (+ theta 9) 360))
      (setq rad (deg2rad theta))

      (setq x (+ *x-param* (* *radius* (cos rad))))
      (setq y (+ *y-param* (* *radius* (sin rad))))
      (setq z *z-param*)

      (setq point-vector
            (float-vector x y z))

      (print "publish data")
      (format t "x: ~A   y: ~A   z: ~A~%" x y z)

      (setq msg (instance geometry_msgs::PointStamped :init
                          :header
                          (instance std_msgs::header :init
                                    :stamp (ros::time-now)
                                    :frame_id "left")
                          :point (ros::pos->tf-point point-vector)
                          ))

      (ros::publish "centroid_calc_from_stereo_image" msg)

      (unix::usleep (* 1000 ds));; ds s
    )
  )
)

;; *x-param* *y-param* *z-param* *radius* *hz*
(test_data4 300 500 1000 100 5)
