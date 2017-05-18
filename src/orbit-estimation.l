#!/usr/bin/env roseus

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")

(setq *z-param* 10)

(defun callback-coordinate (msg)
  (setq *coordinate-msg* msg)
  )

(defun sum(input)
  (let ((tempsum 0))
    (if (atom input)
        (if (vectorp input)
                (setq input (coerce input cons))
              (if (numberp input)
                  (setq input (list input))
                        (return-from average 0))))
    (dotimes (i (length input))
      (setf tempsum (+ tempsum (elt input i))))
    tempsum))


(defun listcross (list1 list2)
  (setq templist (make-array (length list1) :initial-element 0.0))
  (dotimes (i (length list1))
    (setf (elt templist i) (* (elt list1 i) (elt list2 i))))
  (coerce templist cons))


(defun regressionline(x-list y-list)
  (let (a b n)
    (if
        (not (equal (length x-list) (length y-list)))
        (return-from regressionline nil)
      (progn
        (setf n (length x-list))
        (setf a (/ (- (sum (listcross x-list y-list)) (/ (* (sum x-list) (sum y-list)) n))
                      (- (sum (listcross x-list x-list)) (/ (* (sum x-list) (sum x-list)) n)))) ;;傾き
        (setq b (/ (- (sum y-list) (* a (sum x-list)))n))                                    ;;y切片
        ))
    (print (list a b));;(傾き、切片)を返す。
    ))


(defun orbit-estimate ()
  (ros::roseus "orbit-estimate")
  (ros::advertise "hit_point"
                  geometry_msgs::Point)

  (ros::subscribe "/centroid_calc_from_stereo_image"
                  geometry_msgs::PointStamped
                  #'callback-coordinate 1)

  (let (x-list y-list z-list coordinate tmp)

    (setq x-list (list ))
    (setq y-list (list ))
    (setq z-list (list ))

    (while (ros::ok)

      (setq *coordinate-msg* nil)
      (ros::spin-once)

      (when *coordinate-msg*
        (setq coordinate *coordinate-msg*)

        (when (> (send coordinate :point :z) *z-param*)
          (push (send coordinate :point :x) x-list)
          (push (send coordinate :point :y) y-list)
          (push (send coordinate :point :z) z-list)
          )

        (print ";; msg received~%")
        (print (length x-list))

        (when (> (length x-list) 10)

          (when (> (length x-list) 20)
            (setq tmp (reverse x-list))
            (pop tmp)
            (setq x-list (reverse tmp))
            (setq tmp (reverse y-list))
            (pop tmp)
            (setq y-list (reverse tmp))
            (setq tmp (reverse z-list))
            (pop tmp)
            (setq z-list (reverse tmp))
            )

          (setq z-x_regressionline (regressionline z-list x-list))
          (setq estimate-x (+ (* (car z-x_regressionline) *z-param*) (cadr z-x_regressionline)))

          (print "estimate-x")
          (print estimate-x)

          (setq msg (instance geometry_msgs::Point :init
                              :x estimate-x
                              :y 0
                              :z *z-param*))
          (ros::publish "hit_point" msg)

          (setq coordinate nil)
          )
        )
      (unix::usleep (* 1000 10));; 10ms
      )
    )
  )

(warn "(orbit-estimate)~%")
(orbit-estimate)
