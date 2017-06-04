#!/usr/bin/env roseus

;(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")

(defun callback-left (msg)
  (setq *left-msg* msg)
  )
(setq *left-camera-info* nil)
(setq *right-camera-info* nil)
(defun callback-left-camerainfo (msg)
  (setq *left-camera-info* msg))
(defun callback-right-camerainfo (msg)
  (setq *right-camera-info* msg))

(defun test_data3 (*x-param* *y-param* *z-param* *radius*)

  (ros::roseus "test_data3")
  (ros::advertise "centroid_calc_from_stereo_image"
                  geometry_msgs::PointStamped)
  (ros::subscribe "/pointgrey/left/image_rect_color"
                  sensor_msgs::Image
                  #'callback-left)
  (ros::subscribe "/pointgrey/left/camera_info"
                  sensor_msgs::camerainfo
                  #'callback-left-camerainfo 1)
  (unix::usleep (* 1000 1000))

  (let ((st (ros::time-now)))
    (while (not *left-camera-info*)
      (when (> (send (ros::time- (ros::time-now) st) :to-sec) 10.0)
        (warn ";; timeout, camera-info not found~%")
        (return-from test_data3 nil))
      (unix::usleep (* 1000 100));; sleep 100 ms
      (ros::spin-once)
      )
    )

  (let (header theta rad x y z)

    (setq theta 0)

    (while (ros::ok)

      (setq *left-msg* nil)
      (ros::spin-once)

      (when *left-camera-info*
        (setq left_m *left-msg*)
        (setq header (send left_m :header))

        ;; draw circle
        ;; center: (*x-param* *y-param*)
        ;; radius: *radius*
        (setq theta (mod (+ theta 9) 360))
        (setq rad (deg2rad theta))

        (setq x (+ *x-param* (* *radius* (cos rad))))
        (setq y (+ *y-param* (* *radius* (sin rad))))
        (setq z *z-param*)

        (print "publish data")
        (format t "x: ~A   y: ~A   z: ~A~%" x y z)

        (setq msg (instance geometry_msgs::PointStamped :init
                            :header header
                            :point
                            (instance geometry_msgs::Point :init
                                      :x x
                                      :y y
                                      :z z)))
        (ros::publish "centroid_calc_from_stereo_image" msg)

        (unix::usleep (* 1000 100));; 100ms
      )
    )
  )
)

;(warn "(test_data2)~%")
;; *x-param* *y-param* *z-param* *radius*
(test_data3 300 500 1000 100)
