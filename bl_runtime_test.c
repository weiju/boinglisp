#include <stdlib.h>

#include "chibi.h"
#include "bl_types.h"

void rt_setup(void *userdata)
{
    bl_init();
}

void rt_teardown(void *userdata)
{
    bl_cleanup();
}

CHIBI_TEST(Test_rt_add1)
{
    BLWORD a = BL_INT2FIXNUM(13);
    chibi_assert_eq_int(13, BL_FIXNUM2INT(bl_add(1, a)));
}
CHIBI_TEST(Test_rt_add2)
{
    BLWORD a = BL_INT2FIXNUM(4), b = BL_INT2FIXNUM(7);
    chibi_assert_eq_int(11, BL_FIXNUM2INT(bl_add(2, a, b)));
}
CHIBI_TEST(Test_rt_add3)
{
    BLWORD a = BL_INT2FIXNUM(4), b = BL_INT2FIXNUM(7), c = BL_INT2FIXNUM(3);
    chibi_assert_eq_int(14, BL_FIXNUM2INT(bl_add(3, a, b, c)));
}

CHIBI_TEST(Test_rt_sub1)
{
    BLWORD a = BL_INT2FIXNUM(13);
    chibi_assert_eq_int(13, BL_FIXNUM2INT(bl_sub(1, a)));
}
CHIBI_TEST(Test_rt_sub2)
{
    BLWORD a = BL_INT2FIXNUM(4), b = BL_INT2FIXNUM(7);
    chibi_assert_eq_int(-3, BL_FIXNUM2INT(bl_sub(2, a, b)));
}
CHIBI_TEST(Test_rt_sub3)
{
    BLWORD a = BL_INT2FIXNUM(4), b = BL_INT2FIXNUM(7), c = BL_INT2FIXNUM(3);
    chibi_assert_eq_int(-6, BL_FIXNUM2INT(bl_sub(3, a, b, c)));
}

CHIBI_TEST(Test_rt_mul1)
{
    BLWORD a = BL_INT2FIXNUM(13);
    chibi_assert_eq_int(13, BL_FIXNUM2INT(bl_mul(1, a)));
}
CHIBI_TEST(Test_rt_mul2)
{
    BLWORD a = BL_INT2FIXNUM(4), b = BL_INT2FIXNUM(7);
    chibi_assert_eq_int(28, BL_FIXNUM2INT(bl_mul(2, a, b)));
}
CHIBI_TEST(Test_rt_mul3)
{
    BLWORD a = BL_INT2FIXNUM(4), b = BL_INT2FIXNUM(7), c = BL_INT2FIXNUM(3);
    chibi_assert_eq_int(84, BL_FIXNUM2INT(bl_mul(3, a, b, c)));
}

CHIBI_TEST(Test_rt_div1)
{
    BLWORD a = BL_INT2FIXNUM(13);
    chibi_assert_eq_int(13, BL_FIXNUM2INT(bl_div(1, a)));
}
CHIBI_TEST(Test_rt_div2)
{
    BLWORD a = BL_INT2FIXNUM(9), b = BL_INT2FIXNUM(3);
    chibi_assert_eq_int(3, BL_FIXNUM2INT(bl_div(2, a, b)));
}
CHIBI_TEST(Test_rt_div3)
{
    BLWORD a = BL_INT2FIXNUM(27), b = BL_INT2FIXNUM(9), c = BL_INT2FIXNUM(3);
    chibi_assert_eq_int(1, BL_FIXNUM2INT(bl_div(3, a, b, c)));
}

CHIBI_TEST(Test_rt_num_eq)
{
    BLWORD a = BL_INT2FIXNUM(9), b = BL_INT2FIXNUM(3), c = BL_INT2FIXNUM(3);
    chibi_assert_eq_int(BL_TRUE, bl_num_eq(2, a, a));
    chibi_assert_eq_int(BL_FALSE, bl_num_eq(2, a, b));
    chibi_assert_eq_int(BL_TRUE, bl_num_eq(2, b, c));
}

CHIBI_TEST(Test_rt_tlenv_lookup_not_exist)
{
    chibi_assert_eq_int(BL_UNDEFINED, bl_tlenv_lookup("notexist"));
}

CHIBI_TEST(Test_rt_tlenv_bind_and_lookup)
{
    chibi_assert_eq_int(BL_UNDEFINED, bl_tlenv_bind("a", BL_INT2FIXNUM(42)));
    chibi_assert_eq_int(BL_INT2FIXNUM(42), bl_tlenv_lookup("a"));
}

CHIBI_TEST(Test_rt_quote)
{
    chibi_assert_eq_int(BL_INT2FIXNUM(42), bl_quote(1, BL_INT2FIXNUM(42)));
    chibi_assert_eq_int(BL_TRUE, bl_quote(1, BL_TRUE));
}

CHIBI_TEST(Test_rt_not)
{
    chibi_assert_eq_int(BL_FALSE, bl_not(1, BL_TRUE));
    chibi_assert_eq_int(BL_TRUE, bl_not(1, BL_FALSE));
}

CHIBI_TEST(Test_rt_local_bind_one)
{
    bl_new_local_env(1);
    bl_local_env_bind(0, 13);
    chibi_assert_eq_int(13, bl_local_env_lookup(0, 0));
}

CHIBI_TEST(Test_rt_local_bind_two)
{
    bl_new_local_env(2);
    bl_local_env_bind(0, 13);
    bl_local_env_bind(1, 14);
    chibi_assert_eq_int(13, bl_local_env_lookup(0, 0));
    chibi_assert_eq_int(14, bl_local_env_lookup(0, 1));
}

int main(int argc, char **argv)
{
    chibi_suite *suite = chibi_suite_new_fixture(rt_setup, rt_teardown, NULL);
    chibi_summary_data summary;
    chibi_suite_add_test(suite, Test_rt_add1);
    chibi_suite_add_test(suite, Test_rt_add2);
    chibi_suite_add_test(suite, Test_rt_add3);

    chibi_suite_add_test(suite, Test_rt_sub1);
    chibi_suite_add_test(suite, Test_rt_sub2);
    chibi_suite_add_test(suite, Test_rt_sub3);

    chibi_suite_add_test(suite, Test_rt_mul1);
    chibi_suite_add_test(suite, Test_rt_mul2);
    chibi_suite_add_test(suite, Test_rt_mul3);

    chibi_suite_add_test(suite, Test_rt_div1);
    chibi_suite_add_test(suite, Test_rt_div2);
    chibi_suite_add_test(suite, Test_rt_div3);

    chibi_suite_add_test(suite, Test_rt_num_eq);
    chibi_suite_add_test(suite, Test_rt_tlenv_lookup_not_exist);
    chibi_suite_add_test(suite, Test_rt_tlenv_bind_and_lookup);
    chibi_suite_add_test(suite, Test_rt_quote);
    chibi_suite_add_test(suite, Test_rt_not);

    chibi_suite_add_test(suite, Test_rt_local_bind_one);
    chibi_suite_add_test(suite, Test_rt_local_bind_two);

    /* chibi_suite_run_tap(suite, &summary);*/
    chibi_suite_run(suite, &summary);
    chibi_suite_delete(suite);
    return summary.num_failures;
}
