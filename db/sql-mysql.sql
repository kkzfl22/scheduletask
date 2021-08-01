/** 任务目录 **/
DROP TABLE IF EXISTS DC_TASK_DIR;
CREATE TABLE DC_TASK_DIR
(
    TASK_DIR_ID          BIGINT(20)   NOT NULL COMMENT '任务目录的ID',
    PARENT_DIR_ID        BIGINT(20) COMMENT '父任务目录的ID',
    TASK_DIR_NAME        VARCHAR(100) NOT NULL COMMENT '任务目录名称',
    TASK_DIR_DESCRIPTION VARCHAR(100) COMMENT '任务目录描述',
    TASK_ORDER           INT(6) COMMENT '排序号',
    CREATOR              VARCHAR(64) DEFAULT NULL COMMENT '创建者',
    UPDATER              VARCHAR(64) DEFAULT NULL COMMENT '更新者',
    CREATE_TIME          DATETIME    DEFAULT NULL COMMENT '创建时间',
    UPDATE_TIME          DATETIME    DEFAULT NULL COMMENT '更新时间',
    PRIMARY KEY (TASK_DIR_ID)
) ENGINE = INNODB
  DEFAULT CHARSET = UTF8 COMMENT ='任务目录信息表';

/** 任务批次信息表 **/
DROP TABLE IF EXISTS DC_BATCH_INFO;

CREATE TABLE DC_BATCH_INFO
(
    BATCH_ID          BIGINT(20)  NOT NULL COMMENT '批次的ID',
    TASK_DIR_ID       BIGINT(20)   DEFAULT NULL COMMENT '所属任务目录ID',
    BATCH_NAME        VARCHAR(40) NOT NULL COMMENT '批次的任务名称',
    BATCH_MSG         VARCHAR(400) DEFAULT NULL COMMENT '批次任务的描述信息',
    BATCH_STATUS      INT(1)      NOT NULL COMMENT '批次任务的状态，1，启用，0，停用',
    BATCH_RUN_STATUS  INT(2)      NOT NULL COMMENT '批次的运行状态,0,初始化，1：运行中，2，运行完成',
    TASK_RUNTIME_FLAG BIGINT(20) COMMENT '每个批次执行时的标识',
    BATCH_CONCURRENT  INT(3)      NOT NULL COMMENT '批次中任务最大并行度，防止一个批次占用过多的线程',
    CREATOR           VARCHAR(64)  DEFAULT NULL COMMENT '创建者',
    UPDATER           VARCHAR(64)  DEFAULT NULL COMMENT '更新者',
    CREATE_TIME       DATETIME     DEFAULT NULL COMMENT '创建时间',
    UPDATE_TIME       DATETIME     DEFAULT NULL COMMENT '更新时间',
    PRIMARY KEY (BATCH_ID)
) ENGINE = INNODB
  DEFAULT CHARSET = UTF8 COMMENT ='批次信息表';

/** 任务主表 **/
DROP TABLE IF EXISTS DC_TASK_INFO;

CREATE TABLE DC_TASK_INFO
(
    TASK_ID     BIGINT(20)  NOT NULL COMMENT '任务的ID,',
    TASK_DIR_ID BIGINT(20)           DEFAULT NULL COMMENT '目录的id',
    TASK_NAME   VARCHAR(60) NOT NULL COMMENT '任务的名称',
    TASK_TYPE   VARCHAR(20) NOT NULL COMMENT '任务的类型:关联DC_TASK_TYPE表',
    STATUS      INT(2)      NOT NULL DEFAULT '1' COMMENT '任务的状态, 1:正常状态,0，停用状态',
    TASK_CFG    VARCHAR(1000)        DEFAULT NULL COMMENT '任务的的配制',
    TASK_RETRY  VARCHAR(10) NOT NULL COMMENT '重试配制:-1,无限重试;5,15,30.执行后5秒重试，以此类推,成功则不再重试。',
    TASK_MSG    VARCHAR(400)         DEFAULT NULL COMMENT '任务的描述',
    CREATOR     VARCHAR(64)          DEFAULT NULL COMMENT '创建者',
    UPDATER     VARCHAR(64)          DEFAULT NULL COMMENT '更新者',
    CREATE_TIME DATETIME             DEFAULT NULL COMMENT '创建时间',
    UPDATE_TIME DATETIME             DEFAULT NULL COMMENT '更新时间',
    PRIMARY KEY (TASK_ID)
) ENGINE = INNODB
  DEFAULT CHARSET = UTF8 COMMENT ='调度任务信息表';


/** 任务类型 **/
DROP TABLE IF EXISTS DC_TASK_TYPE;

CREATE TABLE DC_TASK_TYPE
(
    TYPE      VARCHAR(20) NOT NULL COMMENT '任务的类型,',
    TYPE_NAME VARCHAR(60) NOT NULL COMMENT '类型的信息',
    TYPE_MSG  VARCHAR(10) COMMENT '类型的描述',
    TYPE_CFG  VARCHAR(1000) COMMENT '任务的配制信息,以JSON格式',
    PRIMARY KEY (TYPE)
) ENGINE = INNODB
  DEFAULT CHARSET = UTF8 COMMENT ='调度任务信息表';


/** 批次跟任务的关联关系表 **/
DROP TABLE IF EXISTS DC_BATCH_TASK;
CREATE TABLE DC_BATCH_TASK
(
    BATCH_ID BIGINT(20) NOT NULL COMMENT '批次的ID',
    TASK_ID  BIGINT(20) NOT NULL COMMENT '调度任务信息表(DC_TASK_INFO)中的任务的ID',
    CONSTRAINT PK_DC_BATCH_TASK_ID PRIMARY KEY (BATCH_ID, TASK_ID)
) ENGINE = INNODB
  DEFAULT CHARSET = UTF8 COMMENT ='批次任务信息表';

/** 任务关系依赖表 **/
DROP TABLE IF EXISTS DC_BATCH_TASK_DEPEND;
CREATE TABLE DC_BATCH_TASK_DEPEND
(
    BATCH_ID     BIGINT(20) NOT NULL COMMENT '批次的ID',
    TASK_ID      BIGINT(20) NOT NULL COMMENT '调度任务信息表(DC_TASK_INFO)中的任务的ID',
    PREV_TASK_ID BIGINT(20) NOT NULL COMMENT '依赖的任务的ID',
    CONSTRAINT PK_DC_BATCH_TASK_DEPEND_TASK_ID PRIMARY KEY (BATCH_ID, TASK_ID, PREV_TASK_ID)
) ENGINE = INNODB
  DEFAULT CHARSET = UTF8 COMMENT ='批次中任务依赖关系表';

/** 批次调度表 **/
DROP TABLE IF EXISTS DC_SCHEDULE_CRON;
CREATE TABLE DC_SCHEDULE_CRON
(
    TASK_ID        BIGINT(20)   NOT NULL COMMENT '使用算法生成',
    TASK_TYPE      INT(2)       NOT NULL COMMENT '当前任务的类型, 1:按任务调度,即, DC_TASK中的任务ID, 2:按批次调用，即DC_BATCH_INFO中的批次的ID',
    SCHEDULE_TYPE  VARCHAR(20) COMMENT '类型(月:MONTH,周:WEEK,日:DAY)',
    SCHEDULE_VALUE VARCHAR(200) COMMENT '值(月:1,2,3 周:MON,SUN)',
    SCHEDULE_CRON  VARCHAR(200) NOT NULL COMMENT 'CRON的表达式',
    UI_TIME        VARCHAR(20)  NOT NULL COMMENT 'UI显示和配置的时间',
    CREATOR        VARCHAR(64) DEFAULT NULL COMMENT '创建者',
    UPDATER        VARCHAR(64) DEFAULT NULL COMMENT '更新者',
    CREATE_TIME    DATETIME    DEFAULT NULL COMMENT '创建时间',
    UPDATE_TIME    DATETIME    DEFAULT NULL COMMENT '更新时间',
    PRIMARY KEY (TASK_ID)
) ENGINE = INNODB
  DEFAULT CHARSET = UTF8 COMMENT ='调度的CRON表达式信息表';


/** 批次日志状态表 **/
DROP TABLE IF EXISTS DC_BATCH_LOG;
CREATE TABLE DC_BATCH_LOG
(
    LOG_ID            BIGINT(20)  NOT NULL COMMENT '日志ID',
    BATCH_ID          BIGINT(20)  NOT NULL COMMENT '批次号',
    BATCH_NAME        VARCHAR(40) NOT NULL COMMENT '任务的名称',
    BATCH_CONCURRENT  INT(3)      NOT NULL COMMENT '批次中任务最大并行度，防止一个批次占用过多的线程',
    BATCH_RUN_STATUS  INT(2)      NOT NULL DEFAULT 0 COMMENT '任务的状态:, 1:成功, 2:任务执行中, 0:初始化状态 -1：失败',
    BATCH_MSG         VARCHAR(500) COMMENT '任务日志，成功为空，失败时记录下失败信息',
    BATCH_START_TIME  BIGINT(20) COMMENT '批次的开始时间',
    BATCH_FINISH_TIME BIGINT(20) COMMENT '批次的结束时间',
    TASK_RUNTIME_FLAG BIGINT(20) COMMENT '每个批次执行时的标识',
    PRIMARY KEY (LOG_ID)
) ENGINE = INNODB
  DEFAULT CHARSET = UTF8 COMMENT ='批次的日志批次状态表';

/** 任务日志表 **/
DROP TABLE IF EXISTS DC_TASK_LOG;
CREATE TABLE DC_TASK_LOG
(
    LOG_ID            BIGINT(20)  NOT NULL COMMENT '日志ID',
    BATCH_ID          BIGINT(20)  NOT NULL COMMENT '批次号',
    TASK_ID           BIGINT(20)  NOT NULL COMMENT '任务的ID',
    TASK_NAME         VARCHAR(40) NOT NULL COMMENT '任务名称',
    TASK_STATUS       INT(3)      NOT NULL COMMENT '任务的状态:, 1:成功, 2:任务执行中, -1：失败',
    TASK_RUN_NUM      INT(7) COMMENT '任务的运行次数次数, 从1开始，任务最少执行一次',
    TASK_CFG          VARCHAR(1000) DEFAULT NULL COMMENT '任务的的配制',
    TASK_MSG          VARCHAR(500) COMMENT '日志信息',
    TASK_START_TIME   BIGINT(20)  NOT NULL COMMENT '任务的开始时间',
    TASK_FINISH_TIME  BIGINT(20) COMMENT '任务的结束时间',
    TASK_ORDER        INT(8) COMMENT '当前任务在任务依赖链中的顺序',
    TASK_RUNTIME_FLAG BIGINT(20)  NOT NULL COMMENT '每次执行任务时的一个标识',
    PRIMARY KEY (LOG_ID)
) ENGINE = INNODB
  DEFAULT CHARSET = UTF8 COMMENT ='任务的日志信息表';
