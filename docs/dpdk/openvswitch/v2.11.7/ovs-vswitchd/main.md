# ovs-vswitchd

```c:vswitchd/ovs-vswitchd.c
 72 int
 73 main(int argc, char *argv[])
 74 {
 75     char *unixctl_path = NULL;
 76     struct unixctl_server *unixctl;
 77     char *remote;
 78     bool exiting, cleanup;
 79     struct ovs_vswitchd_exit_args exit_args = {&exiting, &cleanup};
 80     int retval;
 81
 82     set_program_name(argv[0]);
 83     ovsthread_id_init();
 84
 85     dns_resolve_init(true);
 86     ovs_cmdl_proctitle_init(argc, argv);
 87     service_start(&argc, &argv);
 88     remote = parse_options(argc, argv, &unixctl_path);
 89     fatal_ignore_sigpipe();
 90
 91     daemonize_start(true);
 92
 93     if (want_mlockall) {
 94 #ifdef HAVE_MLOCKALL
 95         if (mlockall(MCL_CURRENT | MCL_FUTURE)) {
 96             VLOG_ERR("mlockall failed: %s", ovs_strerror(errno));
 97         }
 98 #else
 99         VLOG_ERR("mlockall not supported on this system");
100 #endif
101     }
102
103     retval = unixctl_server_create(unixctl_path, &unixctl);
104     if (retval) {
105         exit(EXIT_FAILURE);
106     }
107     unixctl_command_register("exit", "[--cleanup]", 0, 1,
108                              ovs_vswitchd_exit, &exit_args);
109
110     bridge_init(remote);
111     free(remote);
112
113     exiting = false;
114     cleanup = false;
115     while (!exiting) {
116         memory_run();
117         if (memory_should_report()) {
118             struct simap usage;
119
120             simap_init(&usage);
121             bridge_get_memory_usage(&usage);
122             memory_report(&usage);
123             simap_destroy(&usage);
124         }
125         bridge_run();
126         unixctl_server_run(unixctl);
127         netdev_run();
128
129         memory_wait();
130         bridge_wait();
131         unixctl_server_wait(unixctl);
132         netdev_wait();
133         if (exiting) {
134             poll_immediate_wake();
135         }
136         poll_block();
137         if (should_service_stop()) {
138             exiting = true;
139         }
140     }
141     bridge_exit(cleanup);
142     unixctl_server_destroy(unixctl);
143     service_stop();
144     vlog_disable_async();
145     ovsrcu_exit();
146     dns_resolve_destroy();
147
148     return 0;
149 }
```
