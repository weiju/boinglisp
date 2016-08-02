#include <stdlib.h>

#include "chibi_test/chibi.h"
#include "bl_environment.h"

CHIBI_TEST(Test_new_tl_env)
{
    struct _bl_toplevel_env *env = bl_new_tl_env();
    chibi_assert_not_null(env);
    chibi_assert_eq_int(0, env->num_entries);
    chibi_assert(env->size > 0);
    bl_free_tl_env(env);
}

CHIBI_TEST(Test_tl_put_get)
{
    struct _bl_toplevel_env *env = bl_new_tl_env();
    bl_tl_env_put(env, "key", 4711);
    chibi_assert_eq_int(4711, bl_tl_env_get(env, "key"));
    bl_free_tl_env(env);
}

CHIBI_TEST(Test_tl_put_twice_and_get)
{
    struct _bl_toplevel_env *env = bl_new_tl_env();
    bl_tl_env_put(env, "key", 1);
    bl_tl_env_put(env, "key", 2);
    chibi_assert_eq_int(2, bl_tl_env_get(env, "key"));
    bl_free_tl_env(env);
}

int main(int argc, char **argv)
{
    chibi_suite *suite = chibi_suite_new();
    chibi_summary_data summary;
    chibi_suite_add_test(suite, Test_new_tl_env);
    chibi_suite_add_test(suite, Test_tl_put_get);
    chibi_suite_add_test(suite, Test_tl_put_twice_and_get);

    /* chibi_suite_run_tap(suite, &summary);*/
    chibi_suite_run(suite, &summary);
    chibi_suite_delete(suite);
    return summary.num_failures;
}
