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
values(1, null, 'ïðåäìåòû', 'ðîäèòåëü', null);
insert into object_types
values(2, 1, 'ìåáåëü', null, null);
insert into object_types
values(3, 1, 'òåõíèêà', null, null);

insert into objects 
values (1, null, 1, 'îôèñ. ìåá.', 'ðîäèòåëü', 1);

insert into objects 
values (2, 1, 2, 'ñòîë', null, 2);
insert into objects 
values (3, 1, 3, 'êîìïüþòåð', null, 3);
insert into objects 
values (4, 1, 3, 'ïðèíòåð', null, 4);

insert into attr_groups
values(1,'âíåøíèé âèä', null);
insert into attr_groups
values(2,'ïðî÷åå', null);


insert into attr_types 
values(1, 'Öâåò', null);
insert into attr_types 
values(2, 'Ìàòåðèàë', null);

insert into attr_types 
values(3, 'Ìàðêà', null);

insert into attr_types 
values(4, 'Ññûëêà', null);

insert into attributes
values(1, 1, 1, 'Öâåò êîìï.', null, 1, null);

insert into attributes
values(2, 1, 1, 'Öâåò ñòîëà.', null, 1, null);

insert into attributes
values(3, 1, 1, 'Öâåò ïðèíò.', null, 1, null);

insert into attributes
values(4, 2, 1, 'ìàòåð. ñòîë', null, 1, null);

insert into attributes
values(5, 3, 2, 'ìàðêà êîìï.', null, 1, null);

insert into params
values(2, 2, 'Êîðè÷íåâûé', null, null);


insert into attributes
values(6, 4, 2, 'Êîìï.-ïðèíò', null, 1, null);
insert into attr_binds 
values(2, 2, null, 1, 'black');

insert into attr_binds 
values(2, 4, null, 1, 'äåðåâî');

insert into attr_binds 
values(3, 1, null, 1, 'áåëûé');

insert into attr_binds 
values(3, 3, null, 1, 'áåëûé');

insert into attr_binds 
values(3, 5, null, 1, 'áåëûé');

insert into attr_binds 
values(3, 6, null, 1, null);

insert into references
values(6, 3, 4, 1);
insert into references
values(6, 4, 3, 1);

insert into params
values(4, 2, 'Äåðåâî', null, null);

insert into params
values(1, 3, 'áåëûé', null, null);

insert into params
values(5, 3, 'Apple', null, null);

insert into params
values(3, 4, '÷åðíûé', null, null);	

--№1 
/*Получение объектов заданного объектного типа(учитывая только наследование ОТ)(ot_id, ot_name, obj_id, obj_name)*/

select attributes.attr_id, attributes.name, attributes.attr_type_id, attr_types.name, attributes.attr_group_id,
attr_groups.name from attributes
left join attr_types on attributes.attr_type_id = attr_types.attr_type_id
left join attr_groups on attributes.attr_group_id = attr_groups.attr_group_id;

--№2   
/*  Получение всех атрибутов для заданного объектного типа, без учета наследования(attr_id, attr_name )*/               
select attributes.attr_id, attributes.name
from attributes
join attr_binds on attributes.attr_id = attr_binds.attr_id where attr_binds.object_type_id =: attr;

--№3 
/*Получение иерархии ОТ(объектных типов)  для заданного объектного типа(нужно получить иерархию наследования) (ot_id, ot_name, level)*/
                 
select ot.obj_type_id as ot_id, ot.name as ot_name, level
FROM obj_types ot
START WITH ot.obj_type_id = 5
CONNECT BY PRIOR ot.parent_id=ot.obj_type_id;

/*Получение вложенности объектов для заданного объекта(нужно получить иерархию вложенности)(obj_id, obj_name, level)*/                    
--№4
SELECT o.object_id as obj_id, o.name as obj_name, level
FROM objects o
START WITH o.object_id = 1
CONNECT BY PRIOR o.object_id=o.parent_id;                    
                    
         
--№5     
/*Получение объектов заданного объектного типа(учитывая только наследование ОТ)(ot_id, ot_name, obj_id, obj_name)*/   
       
select distinct ot.obj_type_id as ot_id, ot.name as ot_name, obj.object_id as obj_id, obj.name as obj_name
from OBJECTS obj,
(select obj_type_id, name from OBJ_TYPES
start with obj_type_id = 2
connect by prior obj_type_id = parent_id
)ot
where obj.obj_type_id=ot.obj_type_id;
select references.reference, attributes.name
from references
join attributes on references.attr_id = attributes.attr_id where references.object_id =: obj;


--№6
/*Получение значений всех атрибутов(всех возможных типов) для заданного объекта(без учета наследования ОТ)(attr_id, attr_name, value)*/

select pr.attr_id as attr_id, at.name as attr_name, pr.value as value
from
(
    with ab as
        (select distinct ab.attr_id, ab.default_value
        from (select object_id, obj_type_id from OBJECTS where object_id=5) obj, ATTR_BINDS ab
        where ab.obj_type_id = obj.obj_type_id)
    select COALESCE(pr.attr_id, ab.attr_id) as attr_id, COALESCE(pr.value, ab.default_value) as value from
    (
        select ref.attr_id, cast (ref.reference as VARCHAR2(20 BYTE)) as value
        from  references ref
        where ref.object_id = 5
        union
        select p.attr_id, p.value_t as value
        from PARAMS p
        where p.object_id = 5
    ) pr
    FULL OUTER JOIN ab on ab.attr_id=pr.attr_id
    order by attr_id
)pr
join attributes at on at.attr_id=pr.attr_id;
         
--№7
/*Получение ссылок на заданный объект(все объекты, которые ссылаются на текущий)(ref_id, ref_name)*/
select references.reference, attributes.name
from references
join attributes on references.attr_id = attributes.attr_id where references.object_id =: obj;

--№8
/*Получение значений всех атрибутов(всех возможных типов, без повторяющихся атрибутов) для заданного объекта( с учетом наследования ОТ) Вывести в виде см. п.6*/

select pr.attr_id as attr_id, at.name as attr_name, pr.value as value
from
(
    with ab as (select distinct ab.attr_id, ab.default_value
        from object_types ot,(select object_id, obj_type_id from objects where object_id =  5) obj, attr_binds ab
        where ab.obj_type_id = ot.obj_type_id
        start with ot.obj_type_id = obj.obj_type_id
        connect by prior ot.parent_id=ot.obj_type_id)
    select COALESCE(pr.attr_id, ab.attr_id) as attr_id, COALESCE(pr.value, ab.default_value) as value from
    (
        select ref.attr_id, cast (ref.reference as VARCHAR2(20 BYTE)) as value
        from  references ref
        where ref.object_id = 5
        union
        select p.attr_id, p.value_t as value
        from PARAMS p
        where p.object_id = 5
    ) pr
    FULL OUTER JOIN ab ON ab.attr_id=pr.attr_id
    order by attr_id
)pr
JOIN attributes at on at.attr_id=pr.attr_id;
        

 
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
