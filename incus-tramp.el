;;; incus-tramp.el --- TRAMP integration for Incus containers -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Lennart C. Karssen <lennart@karssen.org>

;; Author: Lennart C. Karssen <lennart@karssen.org>
;; URL: https://gitlab.com/lckarssen/incus-tramp.git
;; Keywords: incus, convenience
;; Version: 1.1
;; Package-Requires: ((emacs "24.4"))

;; This code is based on lxd-tramp by Yc.S <onixie@gmail.com> from
;; https://github.com/onixie/lxd-tramp.git, adapted to Incus.

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
  '((incus-tramp--list-containers))
  "Default list of (FUNCTION FILE) pairs to be examined for incus method.")

;;;###autoload
(defconst incus-tramp-method "incus"
  "Method to connect to Incus containers.")

(defun incus-tramp--parse-containers (incus-output)
  "Return a list of user (nil) and container combinations.

INCUS-OUTPUT is the output of the incus --list command."
    (list nil
          (car (split-string incus-output "[[:space:]]+" t))))

(defun incus-tramp--list-running-containers ()
  "Get list of running containers."
  (mapcar #'incus-tramp--parse-containers (ignore-errors (process-lines
                                                       "incus" "list"
                                                       "--columns=n"
                                                       "--format=csv"
                                                       "state=running"))))

;;;###autoload
(defun incus-tramp-add-method ()
  "Add incus tramp method."
  (add-to-list 'tramp-methods
               `(,incus-tramp-method
                 (tramp-login-program ,incus-tramp-incus-executable)
                 (tramp-login-args (("exec") ("%h") ("--") ("su - %u")))
                 (tramp-remote-shell "/bin/sh")
                 (tramp-remote-shell-args ("-i" "-c")))))


(provide 'incus-tramp)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; incus-tramp.el ends here
