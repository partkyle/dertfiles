;; this needs to run first for when I eventually
;; break something
(global-set-key
 [f7]
 (lambda () (interactive)
   (find-file "~/.emacs.d/init.el" t)))

(defun jmc-eval-to-here ()
  (interactive)
  (eval-region 0 (point)))
(global-set-key
 [f9]
 'jmc-eval-to-here)

;; fix shift up on xterms
(if (equal "xterm" (tty-type))
    (define-key input-decode-map "\e[1;2A" [S-up]))
(defadvice terminal-init-xterm (after select-shift-up activate)
  (define-key input-decode-map "\e[1;2A" [S-up]))

;; the bell is evil
(setq ring-bell-function 'ignore)

;; make sure all packages are loaded
(require 'cl)
(require 'package)
(package-initialize)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("ELPA" . "http://tromey.com/elpa/") t)

;; preinstall some packages
(defvar prelude-packages
  '(ack-and-a-half auctex clojure-mode coffee-mode deft expand-region
                   gist groovy-mode haml-mode haskell-mode inf-ruby
                   magit magithub markdown-mode paredit php-mode
                   projectile python sass-mode rainbow-mode
                   ruby-electric scss-mode solarized-theme tango-2-theme
                   volatile-highlights yaml-mode yari zenburn-theme)
  "A list of packages to ensure are installed at launch.")

(defun prelude-packages-installed-p ()
  (loop for p in prelude-packages
        when (not (package-installed-p p)) do (return nil)
        finally (return t)))

(unless (prelude-packages-installed-p)
  ;; check for new packages (package versions)
  (message "%s" "Emacs Prelude is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  ;; install the missing packages
  (dolist (p prelude-packages)
    (when (not (package-installed-p p))
      (package-install p))))

(provide 'prelude-packages)

;; look and feel
(if window-system
    (progn
      (set-frame-font "Inconsolata-g-14")
      (delete-selection-mode t)
      (tool-bar-mode -1)
      (blink-cursor-mode -1)
      (load-theme 'solarized-light t)))

(setq inhibit-startup-message t)
(show-paren-mode t)
(column-number-mode t)

;; line numbers don't have to be ugly
(global-linum-mode 1)
(defadvice linum-update-window (around linum-dynamic activate)
  (let* ((w (length (number-to-string
                     (count-lines (point-min) (point-max)))))
         (linum-format (concat "%" (number-to-string w) "d ")))
    ad-do-it))

;; no visual bell
(setq ring-bell-function 'ignore)

(fset 'yes-or-no-p 'y-or-n-p)

(setq make-backup-files nil)
(setq auto-save-default nil)

;; tab settings
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

;; key bindings
(global-set-key (kbd "C-x g") 'grep)
(global-set-key (kbd "C-x C-g") 'grep)
(global-set-key (kbd "C-<f5>") 'linum-mode)
(global-set-key (kbd "C-x C-o") 'other-window)
(global-set-key (kbd "C-S-k") 'kill-whole-line)

;; ido settings (fuzzy finder)
(when (require 'ido)
  (ido-mode t)
  (setq ido-max-directory-size 10000
        Ido-enable-flex-matching t)) ;; enable fuzzy matching

(defun ruby-mode-hook ()
  (autoload 'ruby-mode "ruby-mode" nil t)
  (add-to-list 'auto-mode-alist '("Capfile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Gemfile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Rakefile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Vagrantfile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.rb\\'" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.ru\\'" . ruby-mode))
  (add-hook 'ruby-mode-hook '(lambda ()
                               (setq ruby-deep-arglist t)
                               (setq ruby-deep-indent-paren nil)
                               (setq c-tab-always-indent nil)
                               (require 'inf-ruby)
                               (require 'ruby-compilation))))

;; ruby-electric-mode for ruby scripts
(add-hook 'ruby-mode-hook
      (lambda ()
        (require 'ruby-electric)
        (ruby-electric-mode t)))
