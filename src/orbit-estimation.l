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

(defun listsum (list1 list2)
  (setq templist (make-array (length list1) :initial-element 0.0))
  (dotimes (i (length list1))
    (setf (elt templist i) (+ (elt list1 i) (elt list2 i))))
  (coerce templist cons))

(defun listsqrt (input)
  (setq templist (make-array (length input) :initial-element 0.0))
  (dotimes (i (length input))
    (setf (elt templist i) (sqrt (elt input i))))
  (coerce templist cons))

(defun regressionline(x-list y-list)
  (let (a b n)
    (if
        (not (equal (length x-list) (length y-list)))
        (return-from regressionline nil)
      (progn
        (setf n (length x-list))
        (setf a (/ (- (sum (listcross x-list y-list)) (/ (* (sum x-list) (sum y-list)) n))
                      (- (sum (listcross x-list x-list)) (/ (* (sum x-list) (sum x-list)) n))))
        (setq b (/ (- (sum y-list) (* a (sum x-list)))n))
        ))
    (print (list a b)) ;;y = a*x + b
    ))

(defun quadratic_regression (x-list y-list)
  (let (a b c n mean_x mean_y mean_x2
          sxx sxy sxx2 sx2x2 sx2y)
    (if
        (not (equal (length x-list) (length y-list)))
        (return-from regressionline nil)
      (progn
        (setf n (length x-list))
        (setf mean_x (* (sum x-list) (/ 1.0 n)))
        (setf mean_y (* (sum y-list) (/ 1.0 n)))
        (setf mean_x2 (* (sum (listcross x-list x-list)) (/ 1.0 n)))
        (setf sxx (- mean_x2 (* mean_x mean_x)))
        (setf sxy (- (* (sum (listcross x-list y-list)) (/ 1.0 n)) (* mean_x mean_y)))
        (setf sxx2 (- (* (sum (listcross x-list (listcross x-list x-list))) (/ 1.0 n)) (* mean_x mean_x2)))
        (setf sx2x2 (- (* (sum (listcross x-list (listcross x-list (listcross x-list x-list)))) (/ 1.0 n)) (* mean_x2 mean_x2)))
        (setf sx2y (- (* (sum (listcross y-list (listcross x-list x-list))) (/ 1.0 n)) (* mean_y mean_x2)))
        (setf a (/ (- (* sx2y sxx) (* sxy sxx2)) (- (* sxx sx2x2) (* sxx2 sxx2))))
        (setf b (/ (- (* sxy sx2x2) (* sx2y sxx2)) (- (* sxx sx2x2) (* sxx2 sxx2))))
        (setf c (- (- mean_y (* b mean_x)) (* a mean_x2)))

        ))
    (print (list a b c)) ;;y = a*x*x + b*x + c
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
          (setq est-x (+ (* (car z-x_regressionline) *z-param*) (cadr z-x_regressionline)))

          (print "estimate-x")
          (print est-x)

          (setq meet_zx (sqrt (+ (* *z-param* *z-param*) (* est-x est-x))))

          (setq z-x-list (listsqrt (listsum (listcross x-list x-list) (listcross z-list z-list))))
          (setq y_quadreg (quadratic_regression z-x-list y-list))
          (setq est-y (+ (+ (* (car y_quadreg) (* meet_zx meet_zx)) (* (cadr y_quadreg) meet_zx)) (caddr u_quadreg)))

          (setq msg (instance geometry_msgs::Point :init
                              :x est-x
                              :y est-y
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
