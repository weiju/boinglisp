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

int main(int argc, char **argv)
{
    chibi_suite *suite = chibi_suite_new_fixture(rt_setup, rt_teardown, NULL);
    chibi_summary_data summary;
    chibi_suite_add_test(suite, Test_rt_add1);
    chibi_suite_add_test(suite, Test_rt_add2);

    /* chibi_suite_run_tap(suite, &summary);*/
    chibi_suite_run(suite, &summary);
    chibi_suite_delete(suite);
    return summary.num_failures;
}
