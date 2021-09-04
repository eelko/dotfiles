;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; Disable quit confirmation
(setq confirm-kill-emacs nil)

;; Keep kill and yank commands from polluting the clipboard
;; (setq select-enable-clipboard nil)

;; MacOS key layout compatibility
(cond (IS-MAC
       ;; Paste with Cmd-V
       (global-set-key (kbd "M-v") 'clipboard-yank)
       ;; Quit with Cmd-Q
       (global-set-key (kbd "M-q") 'save-buffers-kill-terminal)))

;; Toggle fullscreen with Cmd-Enter, like iTerm
(defvar obxhdx/toggle-fullscreen-key-seq
  (cond ((eq window-system 'mac) "M-RET")
        ((eq window-system 'ns) "s-<return>")))
(global-set-key (kbd obxhdx/toggle-fullscreen-key-seq) 'toggle-frame-fullscreen)

;; Save buffers when focus is lost
(defun obxhdx/save-buffer-if-modified (&optional buffer)
  "Saves a file-visitting buffer if it's modified."
  (when (and (buffer-file-name buffer)
             (buffer-modified-p buffer))
    (save-buffer buffer)))

(defun obxhdx/save-all-modified-buffers ()
  "Iterates over all buffers in all windows calling `obxhdx/save-buffer-if-modified'"
  (walk-windows (lambda (w)
                  (with-current-buffer (window-buffer w)
                    (obxhdx/save-buffer-if-modified)))))

(add-function :after after-focus-change-function 'obxhdx/save-all-modified-buffers)

;; Highlight current line only on active buffer
(defun obxhdx/disable-hl-line-mode-in-inactive-buffers ()
  "Disable hl-line-mode in inactive buffers."
  (walk-windows (lambda (w)
                  (unless (or (eq w (selected-window))
                              (treemacs-is-treemacs-window? w))
                    (with-current-buffer (window-buffer w)
                      (hl-line-mode -1)))))
  (hl-line-mode +1))

;; Override basic leader-based bindings
(map! :leader
      :desc "Copy to clipboard"     "y"  #'clipboard-kill-ring-save
      :desc "Paste from clipboard"  "p"  #'clipboard-yank
      :desc "Kill current buffer"   "d"  #'kill-this-buffer
      :desc "Save current file"     "w"  #'save-buffer)

;; Readline fixes
(map! :map evil-insert-state-map
      "C-a"  #'beginning-of-line
      "C-b"  #'backward-char
      "C-d"  #'delete-forward-char
      "C-e"  #'end-of-line
      "C-f"  #'forward-char
      "C-h"  #'delete-backward-char
      "C-k"  #'kill-sentence
      "C-u"  #'backward-kill-sentence
      "C-w"  #'evil-delete-backward-word)
(map! :map evil-ex-completion-map ; after pressing ":" in normal mode
      "C-h"  #'delete-backward-char
      "C-w"  #'evil-delete-backward-word)
(map! :map evil-ex-search-keymap ; after pressing "/" in normal mode
      "C-h"  #'delete-backward-char
      "C-w"  #'evil-delete-backward-word)
(map! :map minibuffer-local-map ; after pressing M-:
      "C-h"  #'delete-backward-char
      "C-w"  #'evil-delete-backward-word)

;; Vim+Tmux-like split navigation
(map! :map evil-normal-state-map
      "M-h" #'windmove-left
      "M-l" #'windmove-right
      "M-k" #'windmove-up
      "M-j" #'windmove-down)

;; 😈
(setq evil-kill-on-visual-paste nil) ; Paste in visual mode doesn't yank

;; A more Vim-like behavior
(map! :map evil-normal-state-map
      "C-w o"  #'doom/window-maximize-buffer)
(evil-define-key 'normal 'global
  "Y" "yy") ; Make Y behave like yy (paste in the line below)

;; Centaur
(after! centaur-tabs
  (centaur-tabs-group-by-projectile-project))

(map! :leader
      (:prefix-map ("n" . "navigate")
       :desc "Switch tab group" "g"  #'centaur-tabs-switch-group))

(map! :map evil-normal-state-map
      ;; Cycle through open buffers more easily
      "C-n"  (lambda ()
               (interactive)
               (if (not (centaur-tabs-forward-tab))
                   (centaur-tabs-forward)))
      "C-p"  (lambda ()
               (interactive)
               (if (not (centaur-tabs-backward-tab))
                   (centaur-tabs-backward))))

;; Yaml
(after! yaml
  (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode)))

;; Projectile
(map! :leader
      (:prefix-map ("f" . "file")
       :desc "Find file"  "f"  #'projectile-find-file))

;; Treemacs
(after! treemacs
  (treemacs-filewatch-mode)
  (treemacs-follow-mode)
  (treemacs-project-follow-mode)

  (setq doom-themes-treemacs-theme "doom-colors") ; enables all-the-icons

  (add-hook 'buffer-list-update-hook 'obxhdx/disable-hl-line-mode-in-inactive-buffers)
  )

(with-eval-after-load "treemacs"
  (treemacs-define-custom-icon (all-the-icons-icon-for-file "file.js") "jsx" "tsx")
  (treemacs-define-custom-icon (all-the-icons-alltheicon "react") "jsx" "tsx")
  )

(defun obxhdx/treemacs-find-file ()
  "Open Treemacs pointing to the current file and select Treemacs window."
  (interactive)
  (treemacs-find-file)
  (treemacs-select-window))

(map! :leader
      (:prefix-map ("n" . "navigate")
       :desc "Find current file in explorer"  "f"  #'obxhdx/treemacs-find-file
       :desc "Toggle explorer"                "t"  #'+treemacs/toggle))

(map! :map treemacs-mode-map
      ;; NERDTree-like bindings
      "C-j" #'treemacs-RET-action
      "x"   #'treemacs-collapse-parent-node
      ;; Vim+Tmux-like split navigation
      "M-h" #'windmove-left
      "M-l" #'windmove-right
      "M-k" #'windmove-up
      "M-j" #'windmove-down)

;; VTerm
(after! vterm
  ;; Allow files to be opened directly from vterm
  (push (list "open-file"
              (lambda (path)
                (if-let* ((buf (find-file-noselect path))
                          (window (display-buffer-use-some-window buf nil)))
                    (select-window window)
                  (message "Failed to open file: %s" path))))
        vterm-eval-cmds))

(defun obxhdx/open-terminal-at-right ()
  "Opens a right slipt with a new vterm session."
  (interactive)
  (split-window-horizontally)
  (other-window 1)
  (+vterm/here nil))

(defun obxhdx/open-terminal-at-bottom ()
  "Opens a bottom slipt with a new vterm session."
  (interactive)
  (split-window-vertically)
  (other-window 1)
  (+vterm/here nil))

;; Create split term buffers like Tmux
(define-key key-translation-map (kbd "C-SPC") (kbd "C-c")) ; C-SPC as C-c
(global-set-key (kbd "C-c v") 'obxhdx/open-terminal-at-right)
(global-set-key (kbd "C-c s") 'obxhdx/open-terminal-at-bottom)

(map! :map vterm-mode-map
      ;; Readline fixes
      "C-h" #'vterm-send-backspace
      "C-u" #'vterm-send-C-u
      ;; Vim+Tmux-like split navigation
      "M-h" #'windmove-left
      "M-l" #'windmove-right
      "M-k" #'windmove-up
      "M-j" #'windmove-down)

(add-hook! 'vterm-mode-hook
  (centaur-tabs-local-mode) ;; No tabs
  (evil-emacs-state)) ; No Evil mode in terminal

(add-hook 'vterm-exit-functions
          (lambda (_ _)
            (let* ((buffer (current-buffer))
                   (window (get-buffer-window buffer)))
              (when (not (one-window-p))
                (delete-window window))
              (kill-buffer buffer))))

;; Sensitive/Temporary configs
(defvar-local local-config-file "~/.emacs.local.el")
(if (file-exists-p local-config-file)
    (load-file local-config-file))
