;;; init.el -- My emacs init

;;; Commentary:

;; @partkyle emacs setup

;;; Code:

;; /usr/local/bin
(setq exec-path (append exec-path '("/usr/local/bin")))

; Stop Emacs from losing undo information by
; setting very high limits for undo buffers
(setq undo-limit 20000000)
(setq undo-strong-limit 40000000)

;; this needs to run first for when I eventually
;; break something
(defun edit-init-el ()
  "Open emacs.d/init.el for editing."
  (interactive)
  (find-file "~/.emacs.d/init.el" t))

(global-set-key [f7] 'edit-init-el)

(defun eval-to-point ()
  "Eval Lisp expression from buffer start to point."
  (interactive)
  (eval-region 0 (point)))

(global-set-key
 [f8]
 'eval-to-point)

;; redo last command
(defun describe-last-function ()
  "Describe the last command that ran."
  (interactive)
  (describe-function last-command))

;; the bell is evil
(setq ring-bell-function 'ignore)

;; change to split after creation
(defadvice split-window (after move-point-to-new-window activate)
  "Move the point to the newly created window after splitting."
  (other-window 1))

(defun smart-line-beginning ()
  "Alternate between line start and text start."
  (interactive)
  (let ((pt (point)))
    (beginning-of-line)
    (when (eq pt (point))
      (beginning-of-line-text))))

(global-set-key (kbd "C-a") 'smart-line-beginning)

;; TODO(partkyle): all of my todos!
;; FIXME: it doesn't need FIXME
;; TODO: NOTHING is left TODO
;; IMPORTANT(partkyle): we need to keep this because it's IMPORTANT
;; BUG: it's not a BUG!
;; XXX: this one too for some reason
;; NOTE(partkyle): don't forget to leave a note
(defun partkyle/highlight-todo ()
  "Highlight all instances of TODO FIXME IMPORTANT BUG NOTE and XXX."
  (font-lock-add-keywords nil
                          '(("\\<\\(XXX\\):" 1 font-lock-warning-face t)
                            ("\\<\\(XXX\\)(.*):" 1 font-lock-warning-face t)
                            ("\\<\\(TODO\\):" 1 font-lock-warning-face t)
                            ("\\<\\(TODO\\)(.*):" 1 font-lock-warning-face t)
                            ("\\<\\(BUG\\):" 1 font-lock-warning-face t)
                            ("\\<\\(BUG\\)(.*):" 1 font-lock-warning-face t)
                            ("\\<\\(FIXME\\):" 1 font-lock-warning-face t)
                            ("\\<\\(FIXME\\)(.*):" 1 font-lock-warning-face t)
                            ("\\<\\(NOTE\\):" 1 font-lock-keyword-face t)
                            ("\\<\\(NOTE\\)(.*):" 1 font-lock-keyword-face t)
                            ("\\<\\(IMPORTANT\\):" 1 font-lock-keyword-face t)
                            ("\\<\\(IMPORTANT\\)(.*):" 1 font-lock-keyword-face t))))

(add-hook 'prog-mode-hook 'partkyle/highlight-todo)

;; make sure all packages are loaded
(require 'package)
(package-initialize)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("ELPA" . "http://tromey.com/elpa/") t)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

;;
;; keybindings
;;
(global-set-key (kbd "M-S-<left>") 'previous-buffer)
(global-set-key (kbd "M-S-<right>") 'next-buffer)
(global-set-key (kbd "M-<up>") 'windmove-up)
(global-set-key (kbd "M-<down>") 'windmove-down)
(global-set-key (kbd "M-<left>") 'windmove-left)
(global-set-key (kbd "M-<right>") 'windmove-right)
(global-set-key (kbd "s-<up>") 'windmove-up)
(global-set-key (kbd "s-<down>") 'windmove-down)
(global-set-key (kbd "s-<left>") 'windmove-left)
(global-set-key (kbd "s-<right>") 'windmove-right)
(global-set-key (kbd "s-o") 'helm-find-files)
(global-set-key (kbd "s-p") 'helm-projectile)
(global-set-key (kbd "s-[") 'helm-M-x)
(global-set-key (kbd "s-g") 'ag-project)
(global-set-key (kbd "s-w") 'delete-window)
(global-set-key (kbd "s-b") 'helm-buffers-list)
(global-set-key (kbd "s-/") 'comment-or-uncomment-region)
(global-set-key (kbd "C-c C-/") 'comment-or-uncomment-region)

;; split management
;; (global-set-key (kbd "s-1") 'delete-other-windows)
(global-set-key (kbd "s-1") 'zoom-window-zoom)
(global-set-key (kbd "s-2") 'split-window-below)
(global-set-key (kbd "s-3") 'split-window-right)

;; errors / occur mode / search
(global-set-key (kbd "M-p") 'previous-error)
(global-set-key (kbd "M-n") 'next-error)

(global-set-key (kbd "C-c c") 'compile)
(global-set-key (kbd "C-c C-c") 'recompile)

;; magit
(global-set-key (kbd "M-?") 'magit-status)
(global-set-key (kbd "M-B") 'magit-blame-mode)

;; make the zoom window not apparent (this might be a mistake)
(defvar zoom-window-mode-line-color "Gray")

;; multi cursors - starting to be better than sublime
(global-set-key (kbd "C-.") 'mc/mark-next-like-this)
(global-set-key (kbd "C-,") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-,") 'mc/mark-all-like-this)

;; only highlight after C-SPC C-SPC
(transient-mark-mode -1)

;; smartparens
(require 'smartparens-config)
(smartparens-global-mode t)

(require 'helm-config)
(defvar helm-split-window-in-side-p t)

(add-to-list 'default-frame-alist '(font . "M+ 2m-16"))

;; look and feel
(if window-system
    (progn
      (delete-selection-mode t)

      (tool-bar-mode -1)
      (menu-bar-mode -1)
      (blink-cursor-mode -1)
      (scroll-bar-mode -1)

      ;; professional-theme settings
      (professional-theme)
      (set-face-attribute 'fringe nil :background "#FFFEDE")

      ;; solarized settings
      ;; (load-theme 'solarized-light t)

      ;; cobalt settings
      ;; (color-theme-cobalt)
      ;; ;; 24.4 theme color
      ;; (set-face-attribute 'fringe nil :background "#0A233E")
      ;; ;; 24.3 theme color
      ;; (set-face-attribute 'linum nil :background "#092F4F")
      ))

(when (require 'yaml-mode)
  (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode)))

;; highlight line
(global-hl-line-mode t)

(setq inhibit-startup-message t)
(show-paren-mode t)
(column-number-mode t)

;; expand region
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

(fset 'yes-or-no-p 'y-or-n-p)

(setq make-backup-files nil)
(setq auto-save-default nil)

;; tab settings
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq-default c-default-style "linux"
              c-basic-offset 4)

;; ;; ido settings (fuzzy finder)
(when (require 'ido)
  (ido-mode t)
  (setq-default ido-max-directory-size 10000
                ido-enable-flex-matching t)) ;; enable fuzzy matching

(add-hook 'prog-mode-hook #'global-company-mode)

;; flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)

;; go-mode
(require 'go-mode-autoloads)

(defvar gofmt-command "goimports")

(defun partkyle/go-mode-hook ()
  "Go configuration."
  (go-eldoc-setup)
  (add-hook 'before-save-hook 'gofmt-before-save)
  (setq-default tab-width 4)
  (setq-default indent-tabs-mode t)
  (local-set-key (kbd "M-.") 'godef-jump))

(add-hook 'go-mode-hook 'partkyle/go-mode-hook)

;; projectile
(projectile-global-mode)

(provide 'init)
;;; init.el ends here
