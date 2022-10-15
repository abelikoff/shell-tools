(defvar time-track-file (expand-file-name "~/.time-track.log"))
(defvar time-track-categories
  '("Clients"
    "Coding"
    "Cross-product"
    "Meta"
    "Misc"
    "Other meetings"
    "People management"
    "Personal"
    "Project management"
    "Recruiting"
    "Strategy/Planning"
    "Team meta"))

(defun time-track-add-entry (minutes category project outcome)
  "Track time using ad-hoc entries. Entries are saved in timer-track-file."

  (interactive (list
                (read-number "Minutes: ")
                (read-string "Category: " nil 'time-track-categories)
                (read-string "Project: ")
                (read-string "Outcome: ")))
  (let ((today (format-time-string "%m/%d/%Y")))
    (save-excursion
      (set-buffer (find-file-noselect time-track-file))
      (widen)
      (end-of-buffer)
      ;; try to append new entry to the others with the same date
      (search-backward-regexp (concat "^" today) nil t)
      (if (not (string= (thing-at-point 'line) ""))
          (progn
            (move-end-of-line nil)
            (insert "\n")))
      (insert (format "%s | %d | %s | %s | %s"
                      today minutes category project outcome))
      (save-buffer)
      (kill-buffer))))
