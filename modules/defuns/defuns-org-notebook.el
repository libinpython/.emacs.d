;;; defuns-org-notebook.el

;; Keep track of attachments
(defvar narf-org-attachments-list '() "A list of attachments for the current buffer")
(make-variable-buffer-local 'narf-org-attachments-list)

;;;###autoload
(defun narf/org-start ()
  (interactive)
  (narf:workgroup-new nil "*ORG*" t)
  (cd org-directory)
  (let ((helm-full-frame t))
    (helm-find-files nil))
  (save-excursion
    (neotree-show)))

;;;###autoload
(defun narf/org-notebook-new ()
  (interactive)
  (projectile-invalidate-cache nil)
  (let* ((default-directory org-directory)
         (dir (projectile-complete-dir))
         (narf-org-quicknote-dir dir))
    (when dir
      (narf/org-notebook-quick-note))))

;;;###autoload
(defun narf/org-notebook-quick-note ()
  (interactive)
  (let (text)
    (when (evil-visual-state-p)
      (setq text (buffer-substring-no-properties evil-visual-beginning evil-visual-end)))
    (switch-to-buffer (generate-new-buffer "*quick-note*"))
    (setq default-directory narf-org-quicknote-dir)
    (erase-buffer)
    (insert text)))

;;;###autoload
(defun narf/org-download-dnd (uri action)
  (if (and (eq major-mode 'org-mode)
           (not (image-type-from-file-name uri)))
      (narf:org-attach uri)
    (let ((dnd-protocol-alist
           (rassq-delete-all 'narf/org-download-dnd (copy-alist dnd-protocol-alist))))
      (dnd-handle-one-url nil action uri))))

;;;###autoload (autoload 'narf:org-attach "defuns-org-notebook" nil t)
(evil-define-command narf:org-attach (&optional uri)
  (interactive "<a>")
  (if uri
      (let* ((rel-path (org-download--fullname uri))
             (new-path (f-expand rel-path)))
        (cond ((string-match-p (concat "^" (regexp-opt '("http" "https" "nfs" "ftp" "file")) "://") uri)
               (url-copy-file uri new-path))
              (t (copy-file uri new-path)))
        (unless new-path
          (user-error "No file was provided"))
        (if (evil-visual-state-p)
            (org-insert-link nil (format "./%s" rel-path)
                             (concat (buffer-substring-no-properties (region-beginning) (region-end))
                                     " " (narf/org-attach-icon rel-path)))
          (insert (format "%s [[./%s][%s]]"
                          (narf/org-attach-icon rel-path)
                          rel-path (f-filename rel-path))))
        (when (string-match-p (regexp-opt '("jpg" "jpeg" "gif" "png")) (f-ext rel-path))
          (org-toggle-inline-images)))
    (let ((attachments (narf-org-attachments)))
      (unless attachments
        (user-error "No attachments in this file"))
      (helm :sources (helm-build-sync-source "Attachments" :candidates attachments)))))

;;;###autoload
(defun narf/org-attach-icon (path)
  (char-to-string (pcase (downcase (f-ext path))
                    ("jpg" ?) ("jpeg" ?) ("png" ?) ("gif" ?)
                    ("pdf" ?)
                    ("ppt" ?) ("pptx" ?)
                    ("xls" ?) ("xlsx" ?)
                    ("doc" ?) ("docx" ?)
                    ("ogg" ?) ("mp3" ?) ("wav" ?)
                    ("mp4" ?) ("mov" ?) ("avi" ?)
                    ("zip" ?) ("gz" ?) ("tar" ?) ("7z" ?) ("rar" ?)
                    (t ?))))

;;;###autoload
(defun narf/org-attachments ()
  (let ((attachments '())
        element
        file)
    (save-excursion
      (goto-char (point-min))
      (while (progn (org-next-link) (not org-link-search-failed))
        (setq element (org-element-lineage (org-element-context) '(link) t))
        (when element
          (setq file (expand-file-name (org-element-property :path element)))
          (when (and (string= (org-element-property :type element) "file")
                     (string= (concat (f-base (f-dirname file)) "/") org-attach-directory)
                     (file-exists-p file))
            (push file attachments)))))
    (-distinct attachments)))

;;;###autoload
(defun narf/org-cleanup-attachments ()
  (let* ((attachments (narf/org-attachments))
         (to-delete (-difference narf-org-attachments-list attachments)))
    (mapc (lambda (f)
            (message "Deleting attachment: %s" f)
            (delete-file f t))
          to-delete)
    (setq narf-org-attachments-list attachments)))

(provide 'defuns-org-notebook)
;;; defuns-org-notebook.el ends here