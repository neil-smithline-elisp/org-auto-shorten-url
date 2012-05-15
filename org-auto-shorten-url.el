;;; org-auto-shorten-url.el --- Automatically shorten URLs with Bit.ly (by default) in Org Mode.
;; 
;; Author: Neil Smithline
;; Maintainer: Neil Smithline
;; Copyright (C) 2012, Neil Smithline, all rights reserved.
;; Created: Tue May 15 18:28:10 2012 (-0400)
;; Version: 1.0-pre1
;; Last-Updated: Tue May 15 18:31:48 2012 (-0400)
;;           By: Neil Smithline
;;     Update #: 0
;; URL: https://github.com/Neil-Smithline/org-auto-shorten-url
;; More apropos URL: http://bit.ly/K3Vc3d :-)
;; Keywords: org-mode, emacs, url, bitly
;; Compatibility: All modern emacsen
;; 
;; Features that might be required by this library:
;;
;;   `org', `bitly', `defhook'.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Commentary: 
;; Automatically shorten URLs in `org-mode' using Bit.ly or a link
;; shortener of your choice.
;;
;; **** NOTE: This package binds the `]' in `org-mode' overriding
;; **** any other bindings for `]'.
;;
;; Putting:
;;      (require 'org-auto-shorten-url)
;; in your `user-init-file' will enable this module.
;;
;; If you do not routinely use `org-mode', putting
;;      (when-feature-loaded 'org (require 'org-auto-shorten-url))
;; in your `user-init-file' will give you better performance during
;; emacs startup.
;;
;; If needed, you can dowload the `bitly' package at
;; https://github.com/Neil-Smithline/bitly.el and the `defhook'
;; package at https://github.com/Neil-Smithline/defhook.
;;
;; If you don't want to use the `defhook' package you can comment out
;; the `defhook' declaration near the end of this file and the
;; "(require 'defhook)" line near the beginning of the file.
;;
;; Then add these lines to your `user-init-file':
;;
;; (add-hook 'org-mode-hook
;;          (lambda () (local-set-key "]" #'org-auto-shorten-url)))
;;
;; 
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Change Log:
;;      Initial version, 1.0-pre1, Tue May 15 18:33:51 2012 (-0400)
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Code:

(require 'bitly)
(require 'defhook)

(defcustom org-auto-shorten-url-function #'bitly-shorten
  "Function that `org-auto-shorten-url' will use to shorten URLs.
The function will be passed three arguments: the url to shorten,
the start position of the URL in the current buffer, and the end
position of the URL in the current buffer.

As URL shortening typically involves contacting a web site,
shortening the URL asynchronously can should eliminate any delay
for URL shortening. `bitly-shorten' when the variable
`bitly-shorten-asynchronously' is non-null."
  :type         'function
  :group        'org-link
  :safe         t
  :risky        nil
  )

(defun org-auto-shorten-url (arg)
  "Automatically shorten URLs when bound to `]' in `org-mode'.
Once bound to `]' in `org-mode', `org-mode' links of the form:
    [[http://my-url/][descriptive text]]

will have their URL automatically shortened by the function
specified in the `org-auto-shorten-url-function' when the
first `]', immediately following the URL, is typed. The URL will
only be shortened when the two characters before the URL are
`[['.

`org-mode' also allows URLs of the form:
    [[http://my-url]]

This URL will be shortened and the shortened URL will be shown in
the buffer. If you want the actual URL displayed, entering
    http://my-url
or
    [[http://my-url][http://my-url]]
will both appear and behave the same as
    [[http://my-url]]

You can also use `quoted-insert' when entering the first `]' to
bypass automatic URL shortening."
  (interactive "p")
  ;; `orig-point' is the last character of the URL. It will be the first
  ;; character before the `]'.
  (let ((orig-point (point)))
    (insert-char ?\] arg t)
    (save-excursion
      (goto-char orig-point)
      (let ((url (thing-at-point 'url)))
        (when url
          (goto-char orig-point)
          (let* ((bounds      (bounds-of-thing-at-point 'url))
                 (begin       (car bounds))
                 (end         (cdr bounds)))
            ;; `thing-at-point' when called after:
            ;;     [[http://foo.com][bar
            ;; will return the URL `http://bar'. WTF?!!?
            ;; We'll workaround it here.
            (when (and
                   begin
                   end
                   (>= begin 3)   ; a quick sanity check
                   (string=
                    "[["
                    (buffer-substring-no-properties (- begin 2) begin)))
              (goto-char orig-point)
              (funcall org-auto-shorten-url-function url begin end))))))))

;;; Bind `]' to org-auto-shorten-url in org-mode buffers.
(defhook bind-auto-url-shorten (org-mode-hook)
  (local-set-key "]" #'org-auto-shorten-url))

(provide 'org-auto-shorten-url)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; org-auto-shorten-url.el ends here
