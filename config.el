;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "SunskyXH"
      user-mail-address "sunskyxh@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq doom-font (font-spec :family "Iosevka NF" :size 22 :weight 'regular))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-gruvbox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 't)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
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
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Display the icon for `major-mode' and the encoding format on `doom-modeline'.
(after! doom-modeline
  (setq doom-modeline-major-mode-icon t))

;; Customize `lsp-mode' and `lsp-ui-mode'.
(after! lsp-ui-mode
  (setq lsp-lens-enable t))

;; Disable lsp format for JavaScript and TypeScript
;; We will use `apheleia' which is used by `:format', it will call prettier or biome for JavaScript/TypeScript
(after! lsp-mode
  (setq lsp-eslint-format nil
        lsp-typescript-format-enable nil
        lsp-javascript-format-enable nil
        lsp-inlay-hint-enable t))

;; Config of `lsp-tailwindcss'
(use-package! lsp-tailwindcss
  :after lsp-mode
  :init
  (setq lsp-tailwindcss-add-on-mode t))

(after! lsp-mode
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection (lambda () '("pyrefly" "lsp" "-j" "4")))
    :activation-fn (lsp-activate-on "python")
    :priority 1
    :add-on? t
    :server-id 'pyrefly)))

;; Config of `nyan-mode'
(use-package! nyan-mode
  :config
  (nyan-mode 1))

;; Config of `lsp-biome'
;; format using `apheleia' w/ biome so we disable the lsp format
(use-package! lsp-biome
  :after lsp-mode
  :init
  (setq lsp-biome-add-on-mode t))

;; Config of `apheleia'
;; Preload `apheleia', ensure `apheleia-formatter' is not void when it is used in .dir-locales.el.
(after! format
  (require 'apheleia))
;; Mark `apheleia-formatter' as safe-local-variable, such that when use it in .dir-locales.el, there won't be any warning.
(put 'apheleia-formatter 'safe-local-variable #'symbolp)
(put 'lsp-eslint-enable 'safe-local-variable #'symbolp)
;; Use ruff to format python projects
(after! apheleia
  (setf (alist-get 'python-mode apheleia-mode-alist)
        '(ruff-isort ruff)))

;; Ignore `android' directory (for react-native project)
(after! lsp-mode
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]android\\'"))

;; Keymap for `ast-grep'
(map! :prefix "C-c s"
      "a" #'ast-grep-search
      "A" #'ast-grep-project)

;; temp fix for gutter dose not refersh after vc-status changes
(use-package! magit
  :defer t
  :init
  (defun my/magit-refresh-vc-gutter-hook ()
    (projectile-process-current-project-buffers-current
     (lambda ()
       (when (or (bound-and-true-p diff-hl-mode)
                 (bound-and-true-p diff-hl-dir-mode))
         (diff-hl--update)))))
  :config
  (add-hook! 'magit-refresh-buffer-hook
             #'my/magit-refresh-vc-gutter-hook))

