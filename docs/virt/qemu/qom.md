# QOM(QEMU Object Model)
* QEMU独自のオブジェクト指向を実現するための機構


## Contents
| Link | Description |
| --- | --- |
| [struct TypeImpl](#struct-typeimpl)                             | コンストラクタ(instance_init)、デストラクタ(instance_finalize)が宣言されており、各Classはこの雛形に沿って定義を行う |
| [struct ObjectClass and Object](#struct-objectclass-and-object) | ObjectClassはすべてのClassの親となるClass、Objectはインスタンスの雛形 |
| [object_new](#object_new)                                       | object_new(const char *typename)によって、事前登録されたTypeImplのハッシュテーブルから名前で検索して、そのTypeImplでインスタンス(Object)を作成する |
| [TypeInfoの定義とTypeImplの登録](#define-typeinfo)              | TypeInfoはTypeImplの簡易版で、これを定義しておき、type_registerを利用してTypeInfoをTypeImpleに変換し、TypeImplのハッシュテーブルに登録できる |


## struct TypeImpl
* コンストラクタ(instance_init)、デストラクタ(instance_finalize)が定義されており、インスタンス化する(オブジェクトの実態を作成する)ときに利用される

> qom/object.c
``` c
 42 struct TypeImpl
 43 {
 44     const char *name;
 45
 46     size_t class_size;
 47
 48     size_t instance_size;
 49
 50     void (*class_init)(ObjectClass *klass, void *data);
 51     void (*class_base_init)(ObjectClass *klass, void *data);
 52     void (*class_finalize)(ObjectClass *klass, void *data);
 53
 54     void *class_data;
 55
 56     void (*instance_init)(Object *obj);
 57     void (*instance_post_init)(Object *obj);
 58     void (*instance_finalize)(Object *obj);
 59
 60     bool abstract;
 61
 62     const char *parent;
 63     TypeImpl *parent_type;
 64
 65     ObjectClass *class;
 66
 67     int num_interfaces;
 68     InterfaceImpl interfaces[MAX_INTERFACES];
 69 };
```


## struct ObjectClass and Object
* struct ObjectClassは、すべてのクラスの親となるルートクラス
    * Type typeは、TypeImplを指すポインタで、これでコンストラクタ、デストラクタを持っている状態になる
        * TypeImplをtypeと言いかえるの注意
* struct Objectは、インスタンス(の雛形)

> include/qom/object.h
``` c
  20 struct TypeImpl;
  21 typedef struct TypeImpl *Type;
  22
  23 typedef struct ObjectClass ObjectClass;
  24 typedef struct Object Object;
  25
  26 typedef struct TypeInfo TypeInfo;
  27
  28 typedef struct InterfaceClass InterfaceClass;
  29 typedef struct InterfaceInfo InterfaceInfo;

 391 struct ObjectClass
 392 {
 393     /*< private >*/
 394     Type type;
 395     GSList *interfaces;
 396
 397     const char *object_cast_cache[OBJECT_CLASS_CAST_CACHE];
 398     const char *class_cast_cache[OBJECT_CLASS_CAST_CACHE];
 399
 400     ObjectUnparent *unparent;
 401
 402     GHashTable *properties;
 403 };

 417 struct Object
 418 {
 419     /*< private >*/
 420     ObjectClass *class;
 421     ObjectFree *free;
 422     GHashTable *properties;
 423     uint32_t ref;
 424     Object *parent;
 425 };
```


## object_new
* type_get_by_nameでハッシュテーブルからTypeImplを取得し、object_new_with_typeでTypeのインスタンス(Object)を作成する
    * ハッシュテーブルへのTypeImpleの登録は、後で説明する

> qom/object.c
``` c
 484 static Object *object_new_with_type(Type type)
 485 {
 486     Object *obj;
 487
 488     g_assert(type != NULL);
 489     type_initialize(type);
 490
 491     obj = g_malloc(type->instance_size);  // インスタンスを作成
 492     object_initialize_with_type(obj, type->instance_size, type);  // インスタンスを初期化
 493     obj->free = g_free;
 494
 495     return obj;
 496 }
 497
 498 Object *object_new(const char *typename)
 499 {
 500     TypeImpl *ti = type_get_by_name(typename);
 501
 502     return object_new_with_type(ti);
 503 }
```

* object_initialize_with_typeで、TypeImplのコンストラクタ(instance_init)でObjectを初期化する

> qom/object.c
``` c
 346 static void object_init_with_type(Object *obj, TypeImpl *ti)
 347 {
 348     if (type_has_parent(ti)) {
 349         object_init_with_type(obj, type_get_parent(ti));  // typeが親を持っていたら再帰的に初期化します
 350     }
 351
 352     if (ti->instance_init) {
 353         ti->instance_init(obj);
 354     }
 355 }
 356
 357 static void object_post_init_with_type(Object *obj, TypeImpl *ti)
 358 {
 359     if (ti->instance_post_init) {
 360         ti->instance_post_init(obj);
 361     }
 362
 363     if (type_has_parent(ti)) {
 364         object_post_init_with_type(obj, type_get_parent(ti));
 365     }
 366 }
 367
 368 static void object_initialize_with_type(void *data, size_t size, TypeImpl *type)
 369 {
 370     Object *obj = data;
 371
 372     g_assert(type != NULL);
 373     type_initialize(type);
 374
 375     g_assert_cmpint(type->instance_size, >=, sizeof(Object));
 376     g_assert(type->abstract == false);
 377     g_assert_cmpint(size, >=, type->instance_size);
 378
 379     memset(obj, 0, type->instance_size);
 380     obj->class = type->class;
 381     object_ref(obj);
 382     obj->properties = g_hash_table_new_full(g_str_hash, g_str_equal,
 383                                             NULL, object_property_free);
 384     object_init_with_type(obj, type);
 385     object_post_init_with_type(obj, type);
 386 }
```


<a name="define-typeinfo"></a>
## クラス(TypeInfo)の定義とTypeImplの登録
* TypeInfo型でクラス定義する
    * TypeInfoはTypeImplの簡易版で、登録の際にTypeImplに変換される
* type_initマクロで、TypeImplをハッシュテーブルに登録する

> hw/i386/pc.c
``` c
2405 static const TypeInfo pc_machine_info = {
2406     .name = TYPE_PC_MACHINE,
2407     .parent = TYPE_MACHINE,
2408     .abstract = true,
2409     .instance_size = sizeof(PCMachineState),
2410     .instance_init = pc_machine_initfn,
2411     .class_size = sizeof(PCMachineClass),
2412     .class_init = pc_machine_class_init,
2413     .interfaces = (InterfaceInfo[]) {
2414          { TYPE_HOTPLUG_HANDLER },
2415          { TYPE_NMI },
2416          { }
2417     },
2418 };
2419
2420 static void pc_machine_register_types(void)
2421 {
2422     type_register_static(&pc_machine_info);
2423 }
2424
2425 type_init(pc_machine_register_types)
```


* type_initマクロ
> include/qemu/module.h
``` c
 35 #define module_init(function, type)                                         \
 36 static void __attribute__((constructor)) do_qemu_init_ ## function(void)    \
 37 {                                                                           \
 38     register_module_init(function, type);                                   \
 39 }
 40 #endif
 41
 42 typedef enum {
 43     MODULE_INIT_BLOCK,
 44     MODULE_INIT_OPTS,
 45     MODULE_INIT_QOM,
 46     MODULE_INIT_TRACE,
 47     MODULE_INIT_MAX
 48 } module_init_type;
 49
 50 #define block_init(function) module_init(function, MODULE_INIT_BLOCK)
 51 #define opts_init(function) module_init(function, MODULE_INIT_OPTS)
 52 #define type_init(function) module_init(function, MODULE_INIT_QOM)
```

* register_module_initは、MODULE_INIT_タイプごとに用意されたModuleTypeListにfunctionをModuleTypeEntryとして追加する
> util/module.c
``` c
 63 void register_module_init(void (*fn)(void), module_init_type type)
 64 {
 65     ModuleEntry *e;
 66     ModuleTypeList *l;
 67
 68     e = g_malloc0(sizeof(*e));
 69     e->init = fn;
 70     e->type = type;
 71
 72     l = find_type(type);
 73
 74     QTAILQ_INSERT_TAIL(l, e, node);
 75 }
```

* type_newでTypeInfoからTypeを生成し、type_table_addでtype_tableという<型の名前,Type>のハッシュテーブルに登録する
> qom/object.c
``` c
  86 static void type_table_add(TypeImpl *ti)
  87 {
  88     assert(!enumerating_types);
  89     g_hash_table_insert(type_table_get(), (void *)ti->name, ti);
  90 }

 134 static TypeImpl *type_register_internal(const TypeInfo *info)
 135 {
 136     TypeImpl *ti;
 137     ti = type_new(info);
 138
 139     type_table_add(ti);
 140     return ti;
 141 }
 142
 143 TypeImpl *type_register(const TypeInfo *info)
 144 {
 145     assert(info->parent);
 146     return type_register_internal(info);
 147 }
 148
 149 TypeImpl *type_register_static(const TypeInfo *info)
 150 {
 151     return type_register(info);
 152 }
```
