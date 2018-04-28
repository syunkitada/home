# Main


## Contents
| Link | Description |
| --- | --- |
| [vl.c](#vl.c) | main関数が定義されてるファイル |


## vl.c
> vl.c
``` c
3091 int main(int argc, char **argv, char **envp)
3092 {
...
// 起動オプションのパース
3229     optind = 1;
3230     for(;;) {
3231         if (optind >= argc)
3232             break;
3233         if (argv[optind][0] != '-') {
3234             hda_opts = drive_add(IF_DEFAULT, 0, argv[optind++], HD_OPTS);
3235         } else {
...
3275             case QEMU_OPTION_blockdev:
3276                 {
3277                     Visitor *v;
3278                     BlockdevOptions_queue *bdo;
3279
3280                     v = qobject_input_visitor_new_str(optarg, "driver", &err);
3281                     if (!v) {
3282                         error_report_err(err);
3283                         exit(1);
3284                     }
3285
3286                     bdo = g_new(BlockdevOptions_queue, 1);
3287                     visit_type_BlockdevOptions(v, NULL, &bdo->bdo,
3288                                                &error_fatal);
3289                     visit_free(v);
3290                     loc_save(&bdo->loc);
3291                     QSIMPLEQ_INSERT_TAIL(&bdo_queue, bdo, entry);
3292                     break;
3293                 }
...
3452             case QEMU_OPTION_netdev:
3453                 default_net = 0;
3454                 if (net_client_parse(qemu_find_opts("netdev"), optarg) == -1) {
3455                     exit(1);
3456                 }
3457                 break;
...
4207             default:
4208                 os_parse_cmd_args(popt->index, optarg);
4209             }
4210         }
4211     }
   
4220     machine_class = select_machine();  // 起動オプションをパースしてMachineClassを選択
4221
4222     set_memory_options(&ram_slots, &maxram_size, machine_class);
4223
4224     os_daemonize();
4225     rcu_disable_atfork();
...
4259     current_machine = MACHINE(object_new(object_class_get_name(  // MachineClassのインスタンス化
4260                           OBJECT_CLASS(machine_class))));
...
4276     cpu_exec_init_all();  // AddressSpaceの初期化
...
4537     configure_accelerator(current_machine);  // kvmの初期化(kvm-all.c: kvm_init)
...
4608     cpu_ticks_init();
...
4630     colo_info_init();
...
4658     blk_mig_init();
4659     ram_mig_init();
...
4668     /* open the virtual block devices */
4669     while (!QSIMPLEQ_EMPTY(&bdo_queue)) {  // bdo_queueには起動オプションで指定したデバイスが登録されている
4670         BlockdevOptions_queue *bdo = QSIMPLEQ_FIRST(&bdo_queue);
4671
4672         QSIMPLEQ_REMOVE_HEAD(&bdo_queue, entry);
4673         loc_push_restore(&bdo->loc);
4674         qmp_blockdev_add(bdo->bdo, &error_fatal);
4675         loc_pop(&bdo->loc);
4676         qapi_free_BlockdevOptions(bdo->bdo);
4677         g_free(bdo);
4678     }
...
4753     machine_run_board_init(current_machine);  // machineの初期化
4754
4755     realtime_init();
...
4784     cpu_synchronize_all_post_init();
4785
4786     rom_reset_order_override();
...
4866     qemu_run_machine_init_done_notifiers();  // machine_init_done_notifiersに登録された処理を実行する
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
