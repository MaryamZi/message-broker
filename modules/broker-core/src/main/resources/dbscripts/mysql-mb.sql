/*
 * Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

-- WSO2 Message Broker MySQL Database schema --

-- Start of Message Store Tables --

CREATE TABLE IF NOT EXISTS MB_EXCHANGE (
                        EXCHANGE_NAME VARCHAR(256) NOT NULL,
                        EXCHANGE_TYPE VARCHAR(256) NOT NULL,
                        PRIMARY KEY(EXCHANGE_NAME)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_QUEUE_METADATA (
                        QUEUE_NAME VARCHAR(256) NOT NULL,
                        QUEUE_ARGUMENTS VARBINARY(10000) NOT NULL,
                        PRIMARY KEY(QUEUE_NAME)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_BINDING (
                        EXCHANGE_NAME VARCHAR(256) NOT NULL,
                        QUEUE_NAME VARCHAR(256) NOT NULL,
                        ROUTING_KEY VARCHAR(256) NOT NULL,
                        ARGUMENTS VARBINARY(2048) NOT NULL,
                        PRIMARY KEY (EXCHANGE_NAME, QUEUE_NAME, ROUTING_KEY, ARGUMENTS),
                        FOREIGN KEY (EXCHANGE_NAME) REFERENCES MB_EXCHANGE (EXCHANGE_NAME) ON DELETE CASCADE,
                        FOREIGN KEY (QUEUE_NAME) REFERENCES MB_QUEUE_METADATA (QUEUE_NAME) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_METADATA (
                MESSAGE_ID BIGINT,
                EXCHANGE_NAME VARCHAR(256) NOT NULL,
                ROUTING_KEY VARCHAR(256) NOT NULL,
                CONTENT_LENGTH BIGINT NOT NULL,
                MESSAGE_METADATA VARBINARY(65000) NOT NULL,
                PRIMARY KEY (MESSAGE_ID)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_CONTENT (
                MESSAGE_ID BIGINT,
                CONTENT_OFFSET INTEGER,
                MESSAGE_CONTENT VARBINARY(65500) NOT NULL,
                PRIMARY KEY (MESSAGE_ID, CONTENT_OFFSET),
                FOREIGN KEY (MESSAGE_ID) REFERENCES MB_METADATA (MESSAGE_ID)
                ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_QUEUE_MAPPING (
                QUEUE_NAME VARCHAR(256) NOT NULL,
                MESSAGE_ID BIGINT,
                PRIMARY KEY (MESSAGE_ID, QUEUE_NAME),
                FOREIGN KEY (MESSAGE_ID) REFERENCES MB_METADATA (MESSAGE_ID)
                ON DELETE CASCADE,
                FOREIGN KEY (QUEUE_NAME) REFERENCES MB_QUEUE_METADATA (QUEUE_NAME)
                ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO MB_EXCHANGE (EXCHANGE_NAME, EXCHANGE_TYPE)  VALUES('<<default>>', 'direct');
INSERT INTO MB_EXCHANGE (EXCHANGE_NAME, EXCHANGE_TYPE)  VALUES('amq.direct', 'direct');
INSERT INTO MB_EXCHANGE (EXCHANGE_NAME, EXCHANGE_TYPE)  VALUES('amq.topic', 'topic');

-- End of Message Store Tables --

-- Start of event store tables --

CREATE TABLE IF NOT EXISTS MB_MSG_STORE_STATUS (
                        NODE_ID VARCHAR(512) NOT NULL,
                        TIME_STAMP BIGINT,
                        PRIMARY KEY (NODE_ID, TIME_STAMP)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_CLUSTER_COORDINATOR_HEARTBEAT (
                        ANCHOR INT NOT NULL,
                        NODE_ID VARCHAR(512) NOT NULL,
                        LAST_HEARTBEAT BIGINT NOT NULL,
                        THRIFT_HOST VARCHAR(512) NOT NULL,
                        THRIFT_PORT INT NOT NULL,
                        PRIMARY KEY (ANCHOR)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_CLUSTER_NODE_HEARTBEAT (
                        NODE_ID VARCHAR(512) NOT NULL,
                        LAST_HEARTBEAT BIGINT NOT NULL,
                        IS_NEW_NODE TINYINT NOT NULL,
                        CLUSTER_AGENT_HOST VARCHAR(512) NOT NULL,
                        CLUSTER_AGENT_PORT INT NOT NULL,
                        PRIMARY KEY (NODE_ID)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_MEMBERSHIP (
                        EVENT_ID BIGINT NOT NULL AUTO_INCREMENT,
                        NODE_ID VARCHAR(512) NOT NULL,
                        CHANGE_TYPE tinyint(4) NOT NULL,
                        CHANGED_MEMBER_ID VARCHAR(512) NOT NULL,
                        PRIMARY KEY (EVENT_ID)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_CLUSTER_EVENT (
                        EVENT_ID BIGINT NOT NULL AUTO_INCREMENT,
                        ORIGINATED_NODE_ID VARCHAR(512) NOT NULL,
                        DESTINED_NODE_ID VARCHAR(512) NOT NULL,
                        EVENT_ARTIFACT VARCHAR(25) NOT NULL,
                        EVENT_TYPE VARCHAR(25) NOT NULL,
                        EVENT_DETAILS VARCHAR(1024) NOT NULL,
                        EVENT_DESCRIPTION VARCHAR(1024),
                        PRIMARY KEY (EVENT_ID)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- End of store tables --

-- Start of RDBMS based Coordinator Election Tables  --

CREATE TABLE IF NOT EXISTS MB_COORDINATOR_HEARTBEAT (
                        ANCHOR INT NOT NULL,
                        NODE_ID VARCHAR(512) NOT NULL,
                        LAST_HEARTBEAT BIGINT NOT NULL,
                        PRIMARY KEY (ANCHOR)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_NODE_HEARTBEAT (
                        NODE_ID VARCHAR(512) NOT NULL,
                        LAST_HEARTBEAT BIGINT NOT NULL,
                        IS_NEW_NODE TINYINT NOT NULL,
                        PRIMARY KEY (NODE_ID)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- End of RDBMS based Coordinator Election Tables  --