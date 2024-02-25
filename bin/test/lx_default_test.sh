#!/bin/bash

source "$( dirname "${BASH_SOURCE[0]}" )/../../inc/test.sh";

test_lx_default() {

  lx_assert_var LX_STD_DEBUG_OVERRIDE 0;
  lx_assert_var LX_STD_MAIL_OVERRIDE 0;
  lx_assert_var LX_STD_STATUS_OVERRIDE 0;
  lx_assert_var LX_STD_INTERACTIVE_OVERRIDE 0;
  lx_assert_var LX_STD_QUICK_OVERRIDE 0;

  # 2024-02-18 jj5 - debug

  lx_default debug 0;
  lx_assert_var LX_STD_DEBUG 0;
  lx_default debug 1;
  lx_assert_var LX_STD_DEBUG 1;

  lx_default debug no;
  lx_assert_var LX_STD_DEBUG 0;
  lx_default debug yes;
  lx_assert_var LX_STD_DEBUG 1;

  lx_default debug off;
  lx_assert_var LX_STD_DEBUG 0;
  lx_default debug on;
  lx_assert_var LX_STD_DEBUG 1;

  lx_default debug false;
  lx_assert_var LX_STD_DEBUG 0;
  lx_default debug true;
  lx_assert_var LX_STD_DEBUG 1;

  LX_STD_DEBUG_OVERRIDE=1;

  lx_default debug 0;
  lx_assert_var LX_STD_DEBUG 1;

  lx_default debug no;
  lx_assert_var LX_STD_DEBUG 1;

  lx_default debug off;
  lx_assert_var LX_STD_DEBUG 1;

  lx_default debug false;
  lx_assert_var LX_STD_DEBUG 1;

  # 2024-02-18 jj5 - mail

  lx_default mail 0;
  lx_assert_var LX_STD_MAIL 0;
  lx_default mail 1;
  lx_assert_var LX_STD_MAIL 1;

  lx_default mail no;
  lx_assert_var LX_STD_MAIL 0;
  lx_default mail yes;
  lx_assert_var LX_STD_MAIL 1;

  lx_default mail off;
  lx_assert_var LX_STD_MAIL 0;
  lx_default mail on;
  lx_assert_var LX_STD_MAIL 1;

  lx_default mail false;
  lx_assert_var LX_STD_MAIL 0;
  lx_default mail true;
  lx_assert_var LX_STD_MAIL 1;

  LX_STD_MAIL_OVERRIDE=1;

  lx_default mail 0;
  lx_assert_var LX_STD_MAIL 1;

  lx_default mail no;
  lx_assert_var LX_STD_MAIL 1;

  lx_default mail off;
  lx_assert_var LX_STD_MAIL 1;

  lx_default mail false;
  lx_assert_var LX_STD_MAIL 1;

  # 2024-02-18 jj5 - status

  lx_default status 0;
  lx_assert_var LX_STD_STATUS 0;
  lx_default status 1;
  lx_assert_var LX_STD_STATUS 1;

  lx_default status no;
  lx_assert_var LX_STD_STATUS 0;
  lx_default status yes;
  lx_assert_var LX_STD_STATUS 1;

  lx_default status off;
  lx_assert_var LX_STD_STATUS 0;
  lx_default status on;
  lx_assert_var LX_STD_STATUS 1;

  lx_default status false;
  lx_assert_var LX_STD_STATUS 0;
  lx_default status true;
  lx_assert_var LX_STD_STATUS 1;

  LX_STD_STATUS_OVERRIDE=1;

  lx_default status 0;
  lx_assert_var LX_STD_STATUS 1;

  lx_default status no;
  lx_assert_var LX_STD_STATUS 1;

  lx_default status off;
  lx_assert_var LX_STD_STATUS 1;

  lx_default status false;
  lx_assert_var LX_STD_STATUS 1;

  # 2024-02-18 jj5 - interactive

  lx_default interactive 0;
  lx_assert_var LX_STD_INTERACTIVE 0;
  lx_default interactive 1;
  lx_assert_var LX_STD_INTERACTIVE 1;

  lx_default interactive no;
  lx_assert_var LX_STD_INTERACTIVE 0;
  lx_default interactive yes;
  lx_assert_var LX_STD_INTERACTIVE 1;

  lx_default interactive off;
  lx_assert_var LX_STD_INTERACTIVE 0;
  lx_default interactive on;
  lx_assert_var LX_STD_INTERACTIVE 1;

  lx_default interactive false;
  lx_assert_var LX_STD_INTERACTIVE 0;
  lx_default interactive true;
  lx_assert_var LX_STD_INTERACTIVE 1;

  LX_STD_INTERACTIVE_OVERRIDE=1;

  lx_default interactive 0;
  lx_assert_var LX_STD_INTERACTIVE 1;

  lx_default interactive no;
  lx_assert_var LX_STD_INTERACTIVE 1;

  lx_default interactive off;
  lx_assert_var LX_STD_INTERACTIVE 1;

  lx_default interactive false;
  lx_assert_var LX_STD_INTERACTIVE 1;

  # 2024-02-18 jj5 - quick

  lx_default quick 0;
  lx_assert_var LX_STD_QUICK 0;
  lx_default quick 1;
  lx_assert_var LX_STD_QUICK 1;

  lx_default quick no;
  lx_assert_var LX_STD_QUICK 0;
  lx_default quick yes;
  lx_assert_var LX_STD_QUICK 1;

  lx_default quick off;
  lx_assert_var LX_STD_QUICK 0;
  lx_default quick on;
  lx_assert_var LX_STD_QUICK 1;

  lx_default quick false;
  lx_assert_var LX_STD_QUICK 0;
  lx_default quick true;
  lx_assert_var LX_STD_QUICK 1;

  LX_STD_QUICK_OVERRIDE=1;

  lx_default quick 0;
  lx_assert_var LX_STD_QUICK 1;

  lx_default quick no;
  lx_assert_var LX_STD_QUICK 1;

  lx_default quick off;
  lx_assert_var LX_STD_QUICK 1;

  lx_default quick false;
  lx_assert_var LX_STD_QUICK 1;

}

lx_declare_tests "
test_lx_default
";
