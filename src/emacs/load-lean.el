(setq inhibit-startup-screen t)

(if (getenv "LEAN_ROOTDIR")
    (setq lean-rootdir (getenv "LEAN_ROOTDIR"))
    (error "LEAN_ROOTDIR environment variable must be set"))

(if (getenv "LEAN_EMACS_PATH")
    (setq-local lean-emacs-path (getenv "LEAN_EMACS_PATH"))
    (error "LEAN_EMACS_PATH environment variable must be set"))

(setq lean-logo
      (condition-case nil
          (create-image (format "%s/lean.pgm" lean-emacs-path))
        (error nil)))

(setq lean-required-packages '(company dash dash-functional f fill-column-indicator flycheck let-alist s seq))

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(dolist (pkg lean-required-packages) (package-install pkg))

(setq load-path (cons lean-emacs-path load-path))

(require 'lean-mode)

(defun lean-welcome ()
  (let ((cbuf (current-buffer))
        (buf (get-buffer-create "Lean Welcome"))
        (cpoint (point-min)))
    (set-buffer buf)
    (setq fill-column (window-width))
    (if buffer-read-only (toggle-read-only))
    (erase-buffer)
    (insert "\n\n")
    (insert "           ")
    (when lean-logo (insert-image lean-logo))
    (setq cpoint (1+ (point)))
    (insert "\n")
    (insert "\n\nPlease check our website periodically for news of later versions")
    (insert "\nat http://leanprover.github.io")
    (insert "\n\nBug reports and suggestions for improvement should be posted at\nhttps://github.com/leanprover/lean/issues")
    (insert "\n\nTo start using Lean, open a .lean or .hlean file")
    (set-buffer-modified-p nil)
    (text-mode)
    (toggle-read-only)
    (goto-char (point-min))
    (switch-to-buffer buf)
    (set-buffer cbuf)
    buf))

(lean-welcome)
