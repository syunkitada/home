# Main


``` c
3091 int main(int argc, char **argv, char **envp)
3092 {
...
4220     machine_class = select_machine();
4221
4222     set_memory_options(&ram_slots, &maxram_size, machine_class);
4223
4224     os_daemonize();
4225     rcu_disable_atfork();
...
4259     current_machine = MACHINE(object_new(object_class_get_name(
4260                           OBJECT_CLASS(machine_class))));
...
4276     cpu_exec_init_all();
...
4608     cpu_ticks_init();
...
4753     machine_run_board_init(current_machine);
4754
4755     realtime_init();
...
4784     cpu_synchronize_all_post_init();
4785
4786     rom_reset_order_override();
...
4909     os_setup_post();
4910
4911     main_loop();
4912     replay_disable_events();
4913     iothread_stop_all();
4914
4915     pause_all_vcpus();
4916     bdrv_close_all();
4917     res_free();
4918
4919     /* vhost-user must be cleaned up before chardevs.  */
4920     tpm_cleanup();
4921     net_cleanup();
4922     audio_cleanup();
4923     monitor_cleanup();
4924     qemu_chr_cleanup();
4925     user_creatable_cleanup();
4926     /* TODO: unref root container, check all devices are ok */
4927
4928     return 0;
4929 }
```
