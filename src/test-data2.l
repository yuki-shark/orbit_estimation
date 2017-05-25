#!/usr/bin/env roseus

;(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")

(defun test_data2 (*z-param* *error*)
  (ros::roseus "test_data2")
  (ros::advertise "centroid_calc_from_stereo_image"
                  geometry_msgs::PointStamped)
  (ros::advertise "correct_data2"
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

    (while (ros::ok)

      (ros::spin-once)

      ;;test_data2
      (setq s 0)
      (while (> 1000 s)

        (setq ds (+ 30 (random 40)))
        (setq s (+ s ds))
        ;; (setq tmp (+ s ds))
        ;; (setq s tmp)
        (setq ms (* 0.001 s))

        (setq z (- 10000 (* ms vz)))
        (setq x (+ (* z a) b))
        ;(setq z-x (sqrt (+ (* x x) (* (- z b) (- z b)))))
        (setq y (+ (+ (* (* 0.5 g) (* ms ms)) (* vy ms)) h))


        ;;add error
        (setq x (+ x (- (random *error*) (* 0.5 *error*))))
        (setq y (+ y (- (random *error*) (* 0.5 *error*))))
        (setq z (+ z (- (random *error*) (* 0.5 *error*))))


        (print "publish data")
        (format t "x: ~A~%" x)
        (format t "y: ~A~%" y)
        (format t "z: ~A~%" z)

        (setq msg (instance geometry_msgs::PointStamped :init
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
        (ros::publish "correct_data2" cmsg)

        (unix::usleep (* 1000 ds));; ds s
      )
    )
  )
)

;(warn "(test_data2)~%")
(test_data2 100 100)
