/*
  This is the real start of the program, it calls bl_main(), defined by the
  compiler output.
*/
int main(int argc, char **argv)
{
    bl_init();
    bl_main();
    bl_cleanup();
    return 1;
}
