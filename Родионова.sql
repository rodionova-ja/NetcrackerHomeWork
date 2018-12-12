create table object_types (
object_type_id number
primary key,
parent_id number,
name varchar2(20) unique ,
description varchar2(20),
properties varchar2(20));

create table objects (
object_id Number primary key ,
parent_id Number,
object_type_id Number NOT NULL,
name Varchar2(20),
description varchar(20),
order_number number
);

create table attributes (
attr_id Number PRIMARY KEY,
attr_type_id number NOT NULL,
attr_group_id number NOT NULL,
name Varchar2(20),
description varchar(20),
ismultiple number,
properties varchar(20)
);
create table params (
attr_id Number NOT NULL,
object_id Number NOT NULL,
value Varchar2(20),
show_order Number,
date_value Date
);

create table references(
attr_id number NOT NULL,
object_id number NOT NULL,
reference number NOT NULL,
show_order number
);
create table attr_binds(
object_type_id number NOT NULL,
attr_id number NOT NULL,
options varchar(20),
isrequired number,
default_value varchar(20)
);

create table attr_types(
attr_type_id number primary key,
name varchar(20) unique,
properties varchar(20)
);

create table attr_groups(
attr_group_id number primary key,
name varchar(20) unique,
properties varchar(20)
);


alter table object_types add foreign
key (parent_id) references
object_types (object_type_id);

Alter table Attributes add
unique (attr_id,Name);
Alter table Attributes add
foreign key (attr_group_id)
references
attr_groups(attr_group_id);

Alter table Attributes add
foreign key (attr_type_id)
references
attr_types(attr_type_id);



Alter table Params add foreign
key (object_id) references
Objects (object_id) on delete
cascade;
Alter table Params add foreign
key (attr_id) references
Attributes (attr_id) on delete
cascade;

alter table attr_binds add 
foreign key(object_type_id)
references object_types(object_type_id);

alter table attr_binds add 
foreign key(attr_id)
references attributes(attr_id);

alter table references add 
foreign key(attr_id)
references attributes(attr_id);

alter table references add 
foreign key(object_id)
references objects(object_id);

alter table references add 
foreign key(reference)
references objects(object_id);

alter table objects add 
foreign key (parent_id)
references objects(object_id);

insert into object_types
values(1, null, 'предметы', 'родитель', null);
insert into object_types
values(2, 1, 'мебель', null, null);
insert into object_types
values(3, 1, 'техника', null, null);

insert into objects 
values (1, null, 1, 'офис. меб.', 'родитель', 1);

insert into objects 
values (2, 1, 2, 'стол', null, 2);
insert into objects 
values (3, 1, 3, 'компьютер', null, 3);
insert into objects 
values (4, 1, 3, 'принтер', null, 4);

insert into attr_groups
values(1,'внешний вид', null);
insert into attr_groups
values(2,'прочее', null);


insert into attr_types 
values(1, 'Цвет', null);
insert into attr_types 
values(2, 'Материал', null);

insert into attr_types 
values(3, 'Марка', null);

insert into attr_types 
values(4, 'Ссылка', null);

insert into attributes
values(1, 1, 1, 'Цвет комп.', null, 1, null);

insert into attributes
values(2, 1, 1, 'Цвет стола.', null, 1, null);

insert into attributes
values(3, 1, 1, 'Цвет принт.', null, 1, null);

insert into attributes
values(4, 2, 1, 'матер. стол', null, 1, null);

insert into attributes
values(5, 3, 2, 'марка комп.', null, 1, null);

insert into params
values(2, 2, 'Коричневый', null, null);


insert into attributes
values(6, 4, 2, 'Комп.-принт', null, 1, null);
insert into attr_binds 
values(2, 2, null, 1, 'black');

insert into attr_binds 
values(2, 4, null, 1, 'дерево');

insert into attr_binds 
values(3, 1, null, 1, 'белый');

insert into attr_binds 
values(3, 3, null, 1, 'белый');

insert into attr_binds 
values(3, 5, null, 1, 'белый');

insert into attr_binds 
values(3, 6, null, 1, null);

insert into references
values(6, 3, 4, 1);
insert into references
values(6, 4, 3, 1);

insert into params
values(4, 2, 'Дерево', null, null);

insert into params
values(1, 3, 'белый', null, null);

insert into params
values(5, 3, 'Apple', null, null);

insert into params
values(3, 4, 'черный', null, null);	

select attributes.attr_id, attributes.name, attributes.attr_type_id, attr_types.name, attributes.attr_group_id,
attr_groups.name from attributes
left join attr_types on attributes.attr_type_id = attr_types.attr_type_id
left join attr_groups on attributes.attr_group_id = attr_groups.attr_group_id;

select attributes.attr_id, attributes.name
from attributes
join attr_binds on attributes.attr_id = attr_binds.attr_id where attr_binds.object_type_id =: attr;

select object_id, name, level lvl
from objects
where object_type_id in (
select object_type_id
from object_types
start with object_type_id = :type_id
connect by prior object_type_id = parent_id
)
start with object_id = :root_id
connect by parent_id = prior object_id;

select references.reference, attributes.name
from references
join attributes on references.attr_id = attributes.attr_id where references.object_id =: obj;

select distinct ot.obj_type_id as ot_id, ot.name as ot_name, obj.object_id as obj_id, obj.name as obj_name
from OBJECTS obj,
(SELECT obj_type_id, name from OBJ_TYPES
start with obj_type_id = 2
connect by prior obj_type_id = parent_id
)ot
where obj.obj_type_id=ot.obj_type_id;



select params.attr_id, attributes.name, params.value
from params
join attributes on params.attr_id = attributes.attr_id
where object_id =: obj;

select pr.attr_id as attr_id, at.name as attr_name, pr.value as value
from
(
    with ab as (select distinct ab.attr_id, ab.default_value
        from object_types ot,(select object_id, obj_type_id from OBJECTS where object_id=5) obj, attr_binds ab
        where ab.obj_type_id = ot.obj_type_id
        start with ot.obj_type_id = obj.obj_type_id
        connect by prior ot.parent_id=ot.obj_type_id)
    select coalesce(pr.attr_id, ab.attr_id) as attr_id, coalesce(pr.value, ab.default_value) as value from
    (
        select ref.attr_id, cast (ref.refernced_object_id as VARCHAR2(20 BYTE)) as value
        from  references ref
        where ref.object_id = 5
        union
        select p.attr_id, p.value_t as value
        from params p
        where p.object_id = 5
    ) pr
    full outer join ab on ab.attr_id=pr.attr_id
    order by attr_id
)pr
join ATTRIBUTES at on at.attr_id=pr.attr_id;

select o.object_id as obj_id, o.name as obj_name, level
from objects o
start with o.object_id = 1
connect by prior o.object_id=o.parent_id;

delete from references;
delete from params;
delete from attr_binds;
delete from objects;
delete from attributes;
delete from attr_groups;
delete from attr_types;
delete from object_types;

DROP TABLE references;
DROP TABLE params;
DROP TABLE attr_binds;
DROP TABLE objects;
DROP TABLE attributes;
DROP TABLE attr_groups;
DROP TABLE attr_types;
DROP TABLE object_types;