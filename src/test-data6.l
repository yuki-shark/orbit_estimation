#!/usr/bin/env roseus

;(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")

(setq *hz* 50)
(setq *z-param* 1000)


(setq period (/ 1000.0 *hz*))

(defun test_data6 ()
  (ros::roseus "test_data6")
  (ros::advertise "centroid_calc_from_stereo_image"
                  geometry_msgs::PointStamped)
  (ros::advertise "correct_data6"
                  geometry_msgs::Point)

  (let (a b h vz vy g s ds ms tmp x y z cx cy cs)

    (setq a (- (random 0.6) 0.3))
    (setq b (- (random 600) 300))
    (setq h (- (random 600) 300))
    (setq vz (* 10 1000))
    (setq vy (* -4.9 1000))
    (setq g (* 9.8 1000))

    ;correct data1
    (setq cx (+ (* *z-param* a) b))
    ;(setq cz-x (sqrt (+ (* cx cx) (* (- *z-param* b) (- *z-param* b)))))
    (setq cs (* (- 10000 *z-param*) (/ 1.0 vz)))
    (setq cy (+ (+ (* (* 0.5 g) (* cs cs)) (* vy cs)) h))

    ;; init
    (setq start-time (send (ros::time-now) :to-sec))
    (setq before-time start-time)

    (while (ros::ok)

      (ros::spin-once)

      ;;test_data6
      (setq s 0)
      (setq start-time (send (ros::time-now) :to-sec))
      (while (> 1000 s)

        ;;(setq ds (round period))
        ;;(unix::usleep (* 1000 ds));; ds s
        ;;(setq s (+ s ds))
        (setq time-now (ros::time-now))
        (setq ms (- (send time-now :to-sec) start-time))

        ;;(setq ds (round (+ (* period 0.6) (random (round (* period 0.4))))))
        (setq s (* ms 1000))
        ;; (setq tmp (+ s ds))
        ;; (setq s tmp)
        ;(setq ms (* 0.001 s))

        (setq z (- 10000 (* ms vz)))
        (setq x (+ (* z a) b))
        ;(setq z-x (sqrt (+ (* x x) (* (- z b) (- z b)))))
        (setq y (+ (+ (* (* 0.5 g) (* ms ms)) (* vy ms)) h))

        (print "correct data")
        (format t "x: ~A~%" x)
        (format t "y: ~A~%" y)
        (format t "z: ~A~%" z)
        ;; (format t "t: ~A~%" (- (send (ros::time-now) :to-sec) start-time))
        ;; (format t "dt: ~A~%" (- (send (ros::time-now) :to-sec) before-time
        (format t "ms: ~A~%" ms)
        (format t "s: ~A~%" s)

        ;(format t "screen point ~A (left)~%" sp1)

        (setq msg (instance geometry_msgs::PointStamped :init
                            :header
                            (instance std_msgs::header :init
                                      :stamp time-now
                                      :frame_id "left")
                            :point
                            (instance geometry_msgs::Point :init
                                      :x x
                                      :y y
                                      :z z)))

        (ros::publish "centroid_calc_from_stereo_image" msg)

        (setq cmsg (instance geometry_msgs::Point :init
                              :x cx
                              :y cy
                              :z *z-param*))
        (ros::publish "correct_data6" cmsg)
        (setq before-time (send time-now :to-sec))

        (setq ds (round (+ (* period 0.6) (random (round (* period 0.4))))))
        ;;(setq ds (round period))
        (unix::usleep (* 1000 ds));; ds s
        ;(setq s (+ s ds))

        ;;(unix::usleep (* 1000 ds));; ds s
      )
    )
  )
)

;(warn "(test_data6)~%")
(test_data6)
