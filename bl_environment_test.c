#include <stdlib.h>

#include "chibi.h"
#include "bl_environment.h"

CHIBI_TEST(Test_new_dict)
{
    struct stemp_dict *dict = stemp_new_dict();
    chibi_assert_not_null(dict);
    chibi_assert_eq_int(0, dict->num_entries);
    chibi_assert(dict->size > 0);
    stemp_free_dict(dict);
}

CHIBI_TEST(Test_put_get)
{
    struct stemp_dict *dict = stemp_new_dict();
    stemp_dict_put(dict, "key", "value");
    chibi_assert_eq_cstr("value", stemp_dict_get(dict, "key")->cstr_value);
    stemp_free_dict(dict);
}

CHIBI_TEST(Test_put_get_null)
{
    struct stemp_dict *dict = stemp_new_dict();
    stemp_dict_put(dict, "key", NULL);
    chibi_assert_eq_cstr(NULL, stemp_dict_get(dict, "key")->cstr_value);
    stemp_free_dict(dict);
}

CHIBI_TEST(Test_put_twice_and_get)
{
    struct stemp_dict *dict = stemp_new_dict();
    stemp_dict_put(dict, "key", "value1");
    stemp_dict_put(dict, "key", "value2");
    chibi_assert_eq_cstr("value2", stemp_dict_get(dict, "key")->cstr_value);
    stemp_free_dict(dict);
}


int main(int argc, char **argv)
{
    chibi_suite *suite = chibi_suite_new();
    chibi_summary_data summary;
    chibi_suite_add_test(suite, Test_new_dict);
    chibi_suite_add_test(suite, Test_put_get_null);
    chibi_suite_add_test(suite, Test_put_get);

    chibi_suite_add_test(suite, Test_put_twice_and_get);

    /* chibi_suite_run_tap(suite, &summary);*/
    chibi_suite_run(suite, &summary);
    chibi_suite_delete(suite);
    return summary.num_failures;
}
