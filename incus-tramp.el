;;; incus-tramp.el --- TRAMP integration for Incus containers -*- lexical-binding: t; -*-

;; Copyright (C) 2018 Yc.S <onixie@gmail.com>

;; Author: Lennart C. Karssen <lennart@karssen.org>
;; URL: https://gitlab.com/lckarssen/incus-tramp.git
;; Keywords: incus, convenience
;; Version: 0.1
;; Package-Requires: ((emacs "24.4"))

;; This code is basically a copy of
;; lxd-tramp by Yc.S <onixie@gmail.com> from
;; https://github.com/onixie/lxd-tramp.git adapted to Incus.

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; `incus-tramp' offers a TRAMP method for Incus containers
;;
;; ## Usage
;;
;; Offers the TRAMP method `incus` to access running containers
;;
;;     C-x C-f /incus:user@container:/path/to/file
;;
;;     where
;;       user           is the user that you want to use (optional)
;;       container      is the id or name of the container
;;

;;; Code:

(eval-when-compile (require 'cl-lib))
(require 'tramp)
(require 'subr-x)

(defgroup incus-tramp nil
  "TRAMP integration for Incus containers."
  :prefix "incus-tramp-"
  :group 'applications
  :link '(url-link :tag "GitLab" "https://gitlab.com/lckarssen/incus-tramp.git")
  :link '(emacs-commentary-link :tag "Commentary" "incus-tramp"))

(defcustom incus-tramp-incus-executable "incus"
  "Path to the incus executable."
  :type 'string
  :group 'incus-tramp)

;;;###autoload
(defconst incus-tramp-completion-function-alist
  '((incus-tramp--parse-running-containers  ""))
  "Default list of (FUNCTION FILE) pairs to be examined for incus method.")

;;;###autoload
(defconst incus-tramp-method "incus"
  "Method to connect to Incus containers.")

(defun incus-tramp--running-containers ()
  "Collect running container names."
  (cl-rest
   (cl-loop for line in (ignore-errors (process-lines incus-tramp-incus-executable "list" "--columns=n")) ; Note: --format=csv only exists after version 2.13
            for count from 1
            when (cl-evenp count) collect (string-trim (substring line 1 -1)))))

(defun incus-tramp--parse-running-containers (&optional ignored)
  "Return a list of (user host) tuples.

TRAMP calls this function with a filename which is IGNORED.  The
user is an empty string because the incus TRAMP method uses bash
to connect to the default user containers."
  (cl-loop for name in (incus-tramp--running-containers)
           collect (list "" name)))

;;;###autoload
(defun incus-tramp-add-method ()
  "Add incus tramp method."
  (add-to-list 'tramp-methods
               `(,incus-tramp-method
                 (tramp-login-program ,incus-tramp-incus-executable)
                 (tramp-login-args (("exec") ("%h") ("--") ("su - %u")))
                 (tramp-remote-shell "/bin/sh")
                 (tramp-remote-shell-args ("-i" "-c")))))

;;;###autoload
(eval-after-load 'tramp
  '(progn
     (incus-tramp-add-method)
     (tramp-set-completion-function incus-tramp-method incus-tramp-completion-function-alist)))

(provide 'incus-tramp)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; incus-tramp.el ends here
