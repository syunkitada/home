# Open vSwitch

```
$ grep 'main(' **/*.c | grep -v test
lib/conntrack.c:static void *clean_thread_main(void *f_);
lib/conntrack.c:clean_thread_main(void *f_)
lib/daemon-windows.c:extern int main(int argc, char *argv[]);
lib/dpif-netdev.c:static void *pmd_thread_main(void *);
lib/dpif-netdev.c: *         - pmd_thread_main()
lib/dpif-netdev.c:dp_netdev_flow_offload_main(void *data OVS_UNUSED)
lib/dpif-netdev.c:pmd_thread_main(void *f_)
lib/fatal-signal.c: * termination, e.g. when exit() is called or when main() returns.
lib/util.c: * be called at the beginning of main() with "argv[0]" as the argument
ofproto/ofproto-dpif-monitor.c:static void *monitor_main(void *);
ofproto/ofproto-dpif-monitor.c:monitor_main(void * args OVS_UNUSED)
ovn/controller-vtep/ovn-controller-vtep.c:main(int argc, char *argv[])
ovn/controller/ovn-controller.c:main(int argc, char *argv[])
ovn/northd/ovn-northd.c:main(int argc, char *argv[])
ovn/utilities/ovn-nbctl.c:main(int argc, char *argv[])
ovn/utilities/ovn-sbctl.c:main(int argc, char *argv[])
ovn/utilities/ovn-trace.c:main(int argc, char *argv[])
ovsdb/ovsdb-client.c:main(int argc, char *argv[])
ovsdb/ovsdb-server.c:main(int argc, char *argv[])
ovsdb/ovsdb-tool.c:main(int argc, char *argv[])
utilities/nlmon.c:main(int argc OVS_UNUSED, char *argv[])
utilities/ovs-appctl.c:main(int argc, char *argv[])
utilities/ovs-dpctl.c:main(int argc, char *argv[])
utilities/ovs-ofctl.c:main(int argc, char *argv[])
utilities/ovs-vlan-bug-workaround.c:main(int argc, char *argv[])
utilities/ovs-vsctl.c:main(int argc, char *argv[])
vswitchd/ovs-vswitchd.c:main(int argc, char *argv[])
vtep/vtep-ctl.c:main(int argc, char *argv[])
```

```
vswitchd/ovs-vswitchd.c:main(int argc, char *argv[])
ovsdb/ovsdb-server.c:main(int argc, char *argv[])
```

- ovsdb-server
- ovs-vswitchd
