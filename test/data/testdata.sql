-- MySQL dump 10.11
--
-- Host: localhost    Database: openmind_dev
-- ------------------------------------------------------
-- Server version	5.0.45-community-nt

--
-- Table structure for table allocations
--

drop table if exists allocations ;

CREATE TABLE allocations (
  id int(11) NOT NULL auto_increment,
  quantity int(11) NOT NULL default '0',
  comments text,
  user_id int(11) default NULL,
  enterprise_id int(11) default NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  lock_version int(11) default '0',
  allocation_type varchar(30) NOT NULL,
  PRIMARY KEY  (id),
  KEY index_allocations_on_user_id (user_id),
  KEY index_allocations_on_enterprise_id (enterprise_id)
);

--
-- Dumping data for table allocations
--

INSERT INTO allocations VALUES (1,7,'',9,NULL,'2008-01-04 11:00:50','2008-01-04 11:25:09',1,'UserAllocation');
INSERT INTO allocations VALUES (2,109,'Allocation imported by tobrien@scribesoft.com',NULL,1,'2008-01-04 11:03:16','2008-01-04 11:03:16',0,'EnterpriseAllocation');
INSERT INTO allocations VALUES (3,1,'Allocation imported by tobrien@scribesoft.com',NULL,2,'2008-01-04 11:03:16','2008-01-04 11:27:20',1,'EnterpriseAllocation');
INSERT INTO allocations VALUES (4,1,'Allocation imported by tobrien@scribesoft.com',1,NULL,'2008-01-04 11:03:17','2008-01-04 11:03:17',0,'UserAllocation');
INSERT INTO allocations VALUES (5,2,'Allocation imported by tobrien@scribesoft.com',6,NULL,'2008-01-04 11:03:17','2008-01-04 11:03:17',0,'UserAllocation');
INSERT INTO allocations VALUES (6,3,'Allocation imported by tobrien@scribesoft.com',5,NULL,'2008-01-04 11:03:17','2008-01-04 11:03:17',0,'UserAllocation');
INSERT INTO allocations VALUES (7,34,'Allocation imported by tobrien@scribesoft.com',7,NULL,'2008-01-04 11:03:17','2008-01-04 11:03:17',0,'UserAllocation');
INSERT INTO allocations VALUES (8,5,'Allocation imported by tobrien@scribesoft.com',8,NULL,'2008-01-04 11:03:17','2008-01-04 11:03:17',0,'UserAllocation');
INSERT INTO allocations VALUES (9,6,'Allocation imported by tobrien@scribesoft.com',2,NULL,'2008-01-04 11:03:17','2008-01-04 11:03:17',0,'UserAllocation');
INSERT INTO allocations VALUES (10,7,'Allocation imported by tobrien@scribesoft.com',4,NULL,'2008-01-04 11:03:17','2008-01-04 11:03:17',0,'UserAllocation');
INSERT INTO allocations VALUES (11,1,'Allocation imported by tobrien@scribesoft.com',9,NULL,'2008-01-04 11:03:18','2008-01-04 11:23:35',2,'UserAllocation');
INSERT INTO allocations VALUES (12,10,'Allocation imported by tobrien@scribesoft.com',3,NULL,'2008-01-04 11:03:18','2008-01-04 11:03:18',0,'UserAllocation');
INSERT INTO allocations VALUES (13,5,'Allocation imported by mwalker@scribesoft.com',NULL,2,'2008-01-04 11:27:35','2008-01-05 21:57:11',1,'EnterpriseAllocation');
INSERT INTO allocations VALUES (14,5,'Allocation imported by mwalker@scribesoft.com',NULL,2,'2008-01-04 11:27:35','2008-01-04 11:27:35',0,'EnterpriseAllocation');
INSERT INTO allocations VALUES (15,5,'Allocation imported by mwalker@scribesoft.com',1,NULL,'2008-01-04 11:27:35','2008-01-05 21:10:35',1,'UserAllocation');
INSERT INTO allocations VALUES (16,5,'Allocation imported by mwalker@scribesoft.com',6,NULL,'2008-01-04 11:27:35','2008-01-04 11:27:35',0,'UserAllocation');
INSERT INTO allocations VALUES (17,5,'Allocation imported by mwalker@scribesoft.com',5,NULL,'2008-01-04 11:27:35','2008-01-04 11:27:35',0,'UserAllocation');
INSERT INTO allocations VALUES (18,5,'Allocation imported by mwalker@scribesoft.com',7,NULL,'2008-01-04 11:27:35','2008-01-04 11:27:35',0,'UserAllocation');
INSERT INTO allocations VALUES (19,5,'Allocation imported by mwalker@scribesoft.com',8,NULL,'2008-01-04 11:27:35','2008-01-04 11:27:35',0,'UserAllocation');
INSERT INTO allocations VALUES (20,5,'Allocation imported by mwalker@scribesoft.com',3,NULL,'2008-01-04 11:27:35','2008-01-05 23:59:39',3,'UserAllocation');
INSERT INTO allocations VALUES (21,5,'Allocation imported by mwalker@scribesoft.com',3,NULL,'2008-01-04 11:27:35','2008-01-05 23:59:58',1,'UserAllocation');
INSERT INTO allocations VALUES (22,5,'Allocation imported by mwalker@scribesoft.com',9,NULL,'2008-01-04 11:27:35','2008-01-04 11:27:35',0,'UserAllocation');
INSERT INTO allocations VALUES (23,5,'Allocation imported by mwalker@scribesoft.com',3,NULL,'2008-01-04 11:27:35','2008-01-04 11:27:35',0,'UserAllocation');
INSERT INTO allocations VALUES (24,1,'',9,NULL,'2008-01-05 21:37:24','2008-01-05 21:37:24',0,'UserAllocation');
INSERT INTO allocations VALUES (25,1,'',5,NULL,'2008-01-05 21:38:06','2008-01-05 21:38:06',0,'UserAllocation');
INSERT INTO allocations VALUES (26,2,'',1,1,'2008-01-05 23:06:53','2008-01-05 23:06:53',0,'UserAllocation');
INSERT INTO allocations VALUES (27,1,'',1,NULL,'2008-01-05 23:12:29','2008-01-05 23:12:29',0,'UserAllocation');
INSERT INTO allocations VALUES (28,20,'',NULL,2,'2008-01-05 23:12:45','2008-01-05 23:12:45',0,'EnterpriseAllocation');
INSERT INTO allocations VALUES (29,3,'',3,NULL,'2008-01-06 00:00:29','2008-01-06 00:02:18',1,'UserAllocation');
INSERT INTO allocations VALUES (30,1,'x',7,NULL,'2008-01-06 00:13:35','2008-01-06 00:15:10',2,'UserAllocation');

--
-- Table structure for table announcements
--

drop table if exists announcements ;

CREATE TABLE announcements (
  id int(11) NOT NULL auto_increment,
  headline varchar(80) NOT NULL,
  description text,
  lock_version int(11) default '0',
  created_at datetime NOT NULL,
  PRIMARY KEY  (id)
);

--
-- Dumping data for table announcements
--

INSERT INTO announcements VALUES (1,'This is a test','one\r\ntwo\r\nthree\r\nfour',0,'2008-01-11 21:07:07');
INSERT INTO announcements VALUES (2,'and again','for this and that\r\n\r\nWeb Images Maps News Shopping Gmail more â–¼ Blogs Books Calendar Documents Finance Groups Photos Reader Scholar Video YouTube even more Â» Sign in\r\nGoogle     Advanced Search\r\n  Preferences \r\n \r\n Web  Results 1 - 10 of about 8,810 fo',0,'2008-01-11 21:07:33');
INSERT INTO announcements VALUES (3,'one more time','Module\r\nActionView::Helpers::UrlHelper In: vendor/rails/actionpack/lib/action_view/helpers/url_helper.rb  \r\n \r\n\r\nProvides a set of methods for making links and getting URLs that depend on the routing subsystem (see ActionController::Routing). This allows ',0,'2008-01-11 21:08:06');
INSERT INTO announcements VALUES (4,'another test','\r\nRename\r\nRails Migration Cheat Sheet\r\nUse these links to fill your page.\r\n\r\nEdit\r\n  Edit\r\n24 Jul \r\nMake sure you view the (short) screencast by DHH\r\n\r\nVERIFY: To enable full use of ruby schema support, uncomment â€˜config.active_record.schema_format = :rubyâ€™ in your /config/environment. (Update: The rails schema mechanism is the default as of Rails 1.1)\r\n\r\nrake db_schema_dump: run after you create a model to capture the schema.rb \r\nrake db_schema_import: import the schema file into the current database (on error, check if your schema.rb has â€:force => trueâ€ on the create table statements \r\n./script/generate migration MigrationName: generate a new migration with a new â€˜highestâ€™ version (run â€™./script/generate migrationâ€™ for this info at your fingertips) \r\nrake migrate: migrate your current database to the most recent version \r\nrake migrate VERSION=5: migrate your current database to a specific version (in this case, version 5) \r\n(run rake -T for most of this information as rake usage information)\r\n\r\nExample schema.rb:\r\n\r\n\r\nActiveRecord::Schema.define(:version => 2) do\r\n\r\n  create_table \"comments\", :force => true do |t|\r\n    t.column \"body\", :text\r\n    t.column \"post_id\", :integer\r\n  end\r\n\r\n  create_table \"posts\", :force => true do |t|\r\n    t.column \"title\", :string\r\n    t.column \"body\", :text\r\n    t.column \"created_at\", :datetime\r\n    t.column \"author_name\", :string\r\n    t.column \"comments_count\", :integer, :default => 0\r\n  end\r\n\r\nend\r\n\r\nWhat can I do?\r\ncreate_table(name, options) \r\ndrop_table(name) \r\nrename_table(old_name, new_name) \r\nadd_column(table_name, column_name, type, options) \r\nrename_column(table_name, column_name, new_column_name) \r\nchange_column(table_name, column_name, type, options) \r\nremove_column(table_name, column_name) \r\nadd_index(table_name, column_name, index_type) \r\nremove_index(table_name, column_name) \r\nSee the Rails API for details on these.\r\n\r\nExample migration:\r\n\r\n\r\nclass UpdateUsersAndCreateProducts &lt; ActiveRecord::Migration\r\n  def self.up\r\n    rename_column \"users\", \"password\", \"hashed_password\" \r\n    remove_column \"users\", \"email\" \r\n\r\n    create_table \"products\", :force => true do |t|\r\n        t.column \"name\", :text\r\n        t.column \"description\", :text\r\n    end\r\n  end\r\n\r\n  def self.down\r\n    rename_column \"users\", \"hashed_password\", \"password\" \r\n    add_column \"users\", \"email\" \r\n    drop_table \"products\" \r\n  end\r\nend\r\n\r\nExecuting SQL directly\r\nexecute â€œALTER TABLE pages_linked_pages ADD UNIQUE page_id_linked_page_id (page_id,linked_page_id)â€ \r\nRemember to be cautious of DB specific SQL!\r\n\r\nProblems? When the migration fails\r\nTip: if you need to manually override the the schema version that in the DB:\r\n\r\nruby script/runner \'ActiveRecord::Base.connection.execute( \r\n\"INSERT INTO schema_info (version) VALUES(0)\")\'\r\nThanks to the Chad Fowlerâ€™s new Rails Recipes book for this one. Note that (duh) you can run any sql like this. \r\nSnippets\r\nOn OS X, Iâ€™m using TextMate with the syncPEOPLE on Rails v.0.9\r\nTextMate Bundle. This provides the followingâ€¦\r\n(snipped from the release notes)\r\n\r\nSnippets are small capsules of code that are activated by a key sequence followed by the [tab] key. For example, mcdt[tab] will activate the Migration Create and drop table if exists snippet.\r\n\r\nmcdt: Migration Create and drop table if exists \r\nmcc: Migration Create Column \r\nmarc: Migration Add and Remove Column \r\nmct: Migration Create Table \r\nmdt: Migration drop table if exists \r\nmac: Migration Add Column \r\nmrc: Migration Remove Column \r\nSee Also Sami Samhuriâ€™s information for a more complete description of these snippets\r\n\r\nAdditional places to look:\r\nSteve Eichert: Migrations Explained \r\nThe RailsConf 2006 Agile Databases with Migrations Presentation Slides by Damon Clinkscales has a great deal of useful information as well. \r\n Published with Backpack. This page is subject to the terms of service.\r\n',0,'2008-01-11 21:36:36');

--
-- Table structure for table comments
--
drop table if exists comments ;

CREATE TABLE comments (
  id int(11) NOT NULL auto_increment,
  user_id int(11) NOT NULL,
  idea_id int(11) NOT NULL,
  body text,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  lock_version int(11) default '0',
  PRIMARY KEY  (id),
  KEY index_comments_on_user_id (user_id),
  KEY index_comments_on_idea_id (idea_id)
);

--
-- Dumping data for table comments
--

INSERT INTO comments VALUES (1,6,3,'I don\'t really understand, could you clarify this?','2008-01-04 11:04:45','2008-01-04 11:04:45',0);
INSERT INTO comments VALUES (2,9,2,'I think this idea sucks','2008-01-04 11:05:31','2008-01-04 11:05:31',0);
INSERT INTO comments VALUES (3,9,4,'I second this idea!','2008-01-04 11:19:41','2008-01-04 11:19:41',0);
INSERT INTO comments VALUES (4,6,1,'Waht do you think of this?','2008-01-09 00:36:37','2008-01-09 00:36:37',0);
INSERT INTO comments VALUES (5,2,7,'This is one more thing\r\nand\r\n\r\none\r\n\r\ntwo\r\n\r\nthree','2008-01-13 22:48:47','2008-01-13 22:48:47',0);

--
-- Table structure for table enterprises
--
drop table if exists enterprises ;

CREATE TABLE enterprises (
  id int(11) NOT NULL auto_increment,
  name varchar(50) NOT NULL,
  active tinyint(1) NOT NULL default '1',
  lock_version int(11) default '0',
  created_at datetime NOT NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY index_enterprises_on_name (name)
);

--
-- Dumping data for table enterprises
--

INSERT INTO enterprises VALUES (1,'Scribe Software',1,2,'2008-01-03 23:12:59');
INSERT INTO enterprises VALUES (2,'XYZ Consulting Company',1,1,'2008-01-04 10:48:59');
INSERT INTO enterprises VALUES (3,'Company A',1,0,'2008-01-13 22:15:38');
INSERT INTO enterprises VALUES (4,'Company B',1,0,'2008-01-13 22:15:43');
INSERT INTO enterprises VALUES (5,'Company C',1,0,'2008-01-13 22:15:46');
INSERT INTO enterprises VALUES (6,'Company D',1,0,'2008-01-13 22:15:50');
INSERT INTO enterprises VALUES (7,'Company E',1,0,'2008-01-13 22:15:56');
INSERT INTO enterprises VALUES (8,'Company F',1,0,'2008-01-13 22:16:03');
INSERT INTO enterprises VALUES (9,'Company G',1,0,'2008-01-13 22:16:10');
INSERT INTO enterprises VALUES (10,'Company H',1,0,'2008-01-13 22:16:19');
INSERT INTO enterprises VALUES (11,'Z Company',1,0,'2008-01-13 22:17:10');

--
-- Table structure for table ideas
--
drop table if exists ideas ;

CREATE TABLE ideas (
  id int(11) NOT NULL auto_increment,
  user_id int(11) NOT NULL,
  product_id int(11) NOT NULL,
  release_id int(11) default NULL,
  title varchar(100) NOT NULL,
  description text,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  lock_version int(11) default '0',
  merged_to_idea_id int(11) default NULL,
  view_count int(11) NOT NULL default '0',
  PRIMARY KEY  (id),
  UNIQUE KEY index_ideas_on_title (title),
  KEY index_ideas_on_user_id (user_id),
  KEY index_ideas_on_product_id (product_id),
  KEY index_ideas_on_release_id (release_id)
);

--
-- Dumping data for table ideas
--

INSERT INTO ideas VALUES (1,6,2,1,'I think that the ui should use more orange','There are several reasons for htis:\r\n\r\n# one\r\n# two\r\n# three','2008-01-04 10:58:53','2008-01-13 22:47:17',18,NULL,16);
INSERT INTO ideas VALUES (2,6,2,NULL,'Another idea','one\r\ntwo\r\nthree','2008-01-04 10:59:11','2008-01-09 00:30:15',7,1,6);
INSERT INTO ideas VALUES (3,9,2,2,'More Email functionality','By auto-sending emails, my spam filter would get good exercise','2008-01-04 10:59:44','2008-01-04 11:21:34',10,NULL,9);
INSERT INTO ideas VALUES (4,8,2,NULL,'Allow creating links with drag and drop','When you\'re working in the Workbench, allow the user to drag a source field onto a target field to create a data link. ','2008-01-04 11:19:05','2008-01-13 22:46:21',47,NULL,47);
INSERT INTO ideas VALUES (5,12,4,NULL,'Another idea for yet another test data','   \r\n          \r\n \r\n \r\nHOME | SERIES | MOVIES | SPORTS | DOCUMENTARIES | HBO FILMS | SCHEDULE | MOBILE | SHOP HBO | GET HBO \r\n \r\n \r\n    \r\n \r\n   Home\r\n\r\n About the Show\r\n\r\n Episode Guide\r\n\r\n Cast and Crew\r\n\r\n   Community\r\n\r\n News \r\n\r\n Downloads\r\n\r\n   Behind the Scenes\r\n\r\n HBO Mobile\r\n\r\n Shop Rome\r\n\r\n  \r\n \r\n \r\n   \r\n \r\n \r\n  Previous Next   \r\n    \r\n   \"Heroes of the Republic\" \r\n \r\n            \r\n \r\n \r\n \r\n Directed by: Alik Sakharov\r\nWritten by: Mere Smith\r\n\r\nSynopsis\r\n\r\nIn a synagogue in the city, Levi and Timon are side by side, deep in ritual prayer. Far north of Rome, in the woods of Cisalpine Gaul, a bearded Mark Antony brings a slaughtered deer to his starving soldiers. \r\n\r\nCloser to the city, Vorenus and Pullo steer a horse-drawn wagon, the three kids sleeping in the back. Pullo suggests Vorenus might want to avoid the collegium when they get back, since Mark Antony\'s orders no longer stand and it\'s a dangerous place for the kids. But Vorenus insists it\'s the only place where they can live honestly. \r\n\r\nThey\'re interrupted by a roadblock of soldiers from Octavian\'s army who inform Vorenus and Pullo that 15,000 of them have headed back to Rome with the triumphant new \"Caesar\". While the men are distracted, Vorena the Younger nudges her sister awake. The older one tells her they can\'t run off until they get some money. \r\n\r\nBack in Rome, Octavian meets with Cicero, who salutes him as a \"hero of the Republic\" for his victory over Mark Antony. However, Cicero cannot give Octavian the triumph he requests. Cicero states that the victory is not quite complete since Antony is still alive. In fact, he had to send General Lepidus and two legions to finish the job. The Senate leader further warns that the people will not look kindly on such a celebration with Octavian\'s army at the city walls. \r\n\r\nNot to be dissuaded, Octavian suggests another way to celebrate his glory â€” giving him the Consul\'s chair. \"It\'s a vanity, I know, but I think I deserve it, and it will please my men.\" Cicero scoffs â€” he\'s too young to be a Senator, much less Consul; he lacks the experience and connections. Agrippa interjects with a reminder about his army, and Cicero reconsiders â€” on condition that the boy takes his counsel. \"I will not utter a word without your advice, your consent,\" Octavian promises. \r\n\r\nOn her way to meet her brother after his long absence, Octavia tries to convince her mother to come along, but Atia insists the \"ingrate\" must come to her. \r\n\r\nBack at the Aventine, Vorenus introduces his children to the tavern crowd, informing them that his oldest was prostituted and the boy was fathered by another man. \"You will treat them with respect and kindness,\" he demands. Taking the kids to their new room, he tells them things will be awkward between them at first, but family should be together. \"We will not speak of the past,\" he adds. \"Yes, father,\" Vorena the Elder says coldly. \r\n\r\nWhen Octavia tries to get her brother to make peace with their mother, he\'s wounded that she\'s taken her side. \"You know what kind of mother she is...She put her lover to beating me!\" Octavia chastises him for being \"pious\" and throwing the family into terrible debt. He tells her he\'s now Consul of Rome, but she\'s not impressed. \"Why would you invite such trouble?!\" she asks. He dismisses her with talk of how busy he is, but she\'s sure to have the last word: \"What a stupid ass you\'ve become!\" \r\n\r\nNow back in charge of the Aventine, Vorenus tells Mascius that he is third in line behind Pullo. The news doesn\'t sit so well. They\'re interrupted by Lyde, dressed in the nun-like garments of a temple acolyte, eager to see the children again. Vorenus warns her she won\'t be taking the children away from him. \r\n\r\nPullo has his own family problems - Eirene is still upset with him for leaving her in the Aventine with the criminals, while he took off to help Vorenus. \"Him you love. Me, no.\" But Pullo assures her that if they both were drowning in the river, he\'d save her first. \r\n\r\nAt his headquarters, Octavian gets a surprise visit from his mother, who falls to her knees when she sees him, begging his forgiveness. \"I have been wicked and cruel. Beat me! Kill me! ...I spit on that pig Antony for leading me astray. I have been a terrible mother...\" Octavian appears genuinely moved. \"I forgive you,\" he says quietly, as she breaks into sobs, embracing him. \"I can change,\" she tells him. Octavian doesn\'t suspect a thing.\r\n\r\nVorenus takes the kids to a shrine, where a priest cleanses them of \"dark spirits,\" smearing the blood of a sacrificed rooster on their faces. Vorenus thanks the gods for returning his family, and promises to \"renounce darkness and walk in the path of light.\" \r\n\r\nNorth of Rome, Mark Antony\'s men bring him a defeated General Lepidus who is still astonished at how quickly his men deserted to the other side. \"I had no idea how popular you were with the rank and file,\" Lepidus tells his rival. Antony suggests the General was a little too aristocratic; soldiers like \"spit and dirt in their leader.\" Rather than kill him, Antony offers the General the job as his second in command. He accepts, realizing he has no choice.\r\n\r\nWhen Pullo pays a visit to Octavian, the boy inquires about married life. \"Strange awkward arrangement, to be thrust up and bound against another so,\" Octavian says before admitting he\'s been \"looking into\" the idea. As for Vorenus, Pullo explains he\'s under loyal oath to Mark Antony, but will do what\'s best for the city and keep the peace as before. If Antony came back with full armor, however, Vorenus won\'t answer for the future. \r\n\r\nIn the Senate, Cicero presides over Octavian\'s swearing in. The boy takes center stage with confidence, insisting he will honor his \"father\" by ushering in an era of moral virtue and dignity. \"Rome shall be as it once was â€” a proud Republic of virtuous women and honest men.\" The Senators applaud, until he makes his next move. Speaking as \"a grieving son,\" Octavian motions to declare Brutus and Cassius murderers and enemies of the state. A horrified Cicero interrupts to warn him that the unity of the Republic is at stake, but Octavian won\'t be deterred.\r\n\r\n\"I\'ve been outmaneuvered by a child,\" Cicero tells his man Tyro afterward, before dictating a note to Brutus and Cassius.\r\n\r\nAt the Aventine tavern, the two Vorenas sneak coins from their father\'s office. Later that night, Gaia offers herself to Vorenus once more, and this time he takes her up on it, telling her to go as soon as they\'re finished. \"F**k you...I\'m not a whore,\" she scoffs, admitting she thought he liked her. \"Oh, what a happy couple we\'d make,\" Vorenus says scornfully, before demanding she take his money. Hearing the anger in his voice, she finally gives in.\r\n\r\nAt a smoky club, a nervous Agrippa watches as scarcely dressed slave girls dance themselves into a frenzy, musicians play instruments, and guests including Maecenas inhale opium bongs. \"We are seconds to the Consul now, we should not be in such places,\" Agrippa tells his deputy before leaving without him. He spots Octavia on his way out, high as a kite with her friend Jocasta. He scoops her up and carries her back to her mother\'s villa. \"You stupid drunken slut!\" Atia yells when she learns where her daughter has been. While her brother has been in the Forum \"selling piety and virtue to the plebs,\" she\'s been off \"sucking slave c**k at an orgy!\" Octavian will likely banish us both, Atia warns her.\r\n\r\nAgrippa swears he\'ll never tell his commander, and when Atia asks why, he admits his feelings for Octavia with a convincing speech. Turning to Atia, he warns her not to speak to her daughter like that again in his presence.\r\n\r\nHearing the news of Octavian\'s motion, Brutus sees an opportunity. \"He was set to unite the Senate and the people behind him,\" he tells Cassius. \"Now the Senate fears it has created another tyrant.\" And with Octavian\'s four legions and Antony\'s seven, the two are likely to fight each other off for supremacy. \"We need only wait and mop up the survivors.\" They write back to Cicero with their plan. \r\n\r\nVorenus tries to make peace with Memmio and Cotta, claiming he doesn\'t want his children to live in fear and that the new Consul insists on it. Eyeing him suspiciously, they agree on terms for dividing the spoils. After parting ways, Vorenus tells Pullo the truce will give them time to recruit men and restore order. In the meantime, Memmio and Cotta are already disagreeing how to divide their own shares. \r\n\r\nHaving hoarded up some money, the girls escape with Lucius and run to see their Aunt Lyde. They can\'t stay with \"that evil man\" anymore, they tell her; he killed their mother and cast them into slavery and disgrace. Lyde is sympathetic, but warns them of what will befall them in the streets â€” thievery and whoring. She urges them to go back, hide their hatred and be obedient. \"Your mother wants you to live. Believe me this is your only chance.\"\r\n\r\nWith word in from Brutus and Cassius, Cicero demands that Octavian surrender his army. The Senate feels he has used them coercively. And since Brutus and Cassius are returning to the city with 20 legions, a war would not be to his advantage. If he disarms now, Cicero might convince them to treat him leniently, given his young age.\r\n\r\nBack at Caesar\'s villa, an anxious Octavian strategizes with Agrippa and Maecenas. Even if Cicero exaggerates, they still need to gather more legions and they\'re out of cash. Atia interrupts to find her son looking glum.\r\n\r\nA few days later, far north of Rome, Mark Antony plots his return to the city in the spring, when the roads are dry. He\'s interrupted by a surprise visitor: Atia, on a white horse, draped in furs. The two waste no time getting reacquainted, and only after does he ask how she managed to get to him all alone. \"I\'m not alone,\" she smiles. He steps outside his tent to find Octavian waiting on horseback, flanked by Agrippa, Maecenas, and a large legion of men. Antony\'s expression turns cold. The two approach each other silently. Antony holds out his arm and they embrace, solidifying an alliance. \r\n\r\nBack in Rome, Pullo and Eirene join Vorenus and his family for a dinner prepared by the children and served by Gaia, who refuses to look at Vorenus, turning her attentions to Pullo instead. Vorena the Elder smiles at her father for the first time, left hand shaped like horns behind her back, cursing him. \r\n\r\nDiscuss this episode in the Rome Bulletin Board.\r\n\r\n  \r\n   \r\n   Summary - Select a Page:  \r\n   \r\n   \r\n Season 1 Episodes  \r\n \r\n   \r\n \r\n   \r\n \r\n Season 2 Episodes  \r\n \r\n   \r\n \r\n 13 Passover\r\n\r\n14 Son of Hades\r\n\r\n15 These Being the Words of Marcus Tullius Cicero\r\n\r\n16 Testudo et Lepus (The Tortoise and the Hare)\r\n\r\n17 Heroes of the Republic\r\n\r\n18 Philippi\r\n\r\n19 Death Mask\r\n\r\n20 A Necessary Fiction\r\n\r\n21 Deus Impeditio Esuritori Nullus\r\n\r\n22 De Patre Vostro\r\n\r\n  \r\n \r\n   \r\n \r\n \r\n \r\n Inside Rome  \r\n   \r\n   \r\n Rome newsletter\r\nSign up now to get insider information, and exclusive emails about Rome.\r\n    \r\n   \r\n  \r\n \r\n \r\n \r\n Rome Fact\r\n\r\nIf a slave was called upon to give evidence in a Roman court, by law he had to be tortured first.   \r\n \r\n \r\n \r\n    \r\n Rome Revealed\r\nGo Behind the Scenes of the new dramatic series Rome in our new feature \"Rome Revealed.\"   \r\n \r\n \r\n    \r\n Rome: The Book\r\nOrder your copy of the Rome Hardcover Book, now available at the HBO Shop.   \r\n \r\n \r\n \r\n   \r\n \r\n HBO INFO       JOBS AT HBO       CONTACT US      TAKE CONTROL      SITE INDEX      SCHEDULE PDF      REGISTER/SIGN IN  \r\n \r\n \r\n \r\n > Privacy Policy   > Terms of Use   \r\n \r\n Â© 2008 Home Box Office, Inc. All Rights Reserved. \r\nThis website is intended for viewing solely in the United States. This website may contain adult content. \r\n\r\n  \r\n   \r\n1 . 2 . 3 . 4 . 5 . 6','2008-01-13 22:25:15','2008-01-13 22:25:15',1,NULL,1);
INSERT INTO ideas VALUES (6,12,3,NULL,'Yet one more piece of test data',' \r\nUsing Link Tags with JavaScript\r\nHow to get your functions without those buttons \r\n--------------------------------------------------------------------------------\r\n    JS Main  |  Basics  |  Advanced  |  Complete List \r\n\r\n--------------------------------------------------------------------------------\r\nHome/JavaScript/Basics/JS Links \r\n\r\nBrowser Compatibility:    NS3+, IE4+  \r\n\r\nI get this question so much, I figured I\'d better get in gear and write another section to address using the link tag for javascripts (such as new windows), rather than using the old grey button. Well, there are a couple of ways to do this. I\'ll start with the easier to understand version first. \r\n\r\nThe first method is to access a javascript function within the HREF attribute of your link tag. So, if you want to link to another page, you normally write: \r\n\r\n<A HREF=\"nextpage.htm\">Click here</A> \r\n\r\nWell, you can access a javascript function you have written instead by writing the link this way: \r\n\r\n<A HREF=\"javascript:myfunction()\">Click Here</A> \r\n\r\nYes, now you can open that new window without using the grey button. Here is a script to give you the new window: \r\n\r\nFirst, I found that this works much better if you create your own function in the head section first. All this function needs to do is open your new window. So, in your head section, create a function like this: \r\n\r\n<HEAD> \r\n<SCRIPT language=\"JavaScript\"> \r\n<!--hide \r\n\r\nfunction newwindow() \r\n{ \r\nwindow.open(\'jex5.htm\',\'jav\',\'width=300,height=200,resizable=yes\'); \r\n} \r\n//--> \r\n</SCRIPT> \r\n\r\nThe above script will open my \"jex5.htm\" page in a new window. As you know, replace this with url of the page you wish to open, and adjust the other attributes to your liking. If you need to know more about the window.open function, see the Opening a New Window tutorial and learn that first.....then come back and get going with the rest of this section. \r\n\r\nNow go into your body section to wherever you want the link to appear, and write your link tag this way: \r\n\r\n<A HREF=\"javascript:newwindow()\" >Click Here!</A> \r\n\r\nNow you will get a link like the one below. Give it a try and see the new window appear when you click the link! \r\n\r\nClick Here! \r\n\r\nFor those of you who want to use an image for the link, just do the normal \"image inside the link tag\" trick, but with the link tag modified for javascript like above: \r\n\r\n<A HREF=\"javascript:newwindow()\" ><IMG SRC=\"scare.jpg\" border=\"0\"></A> \r\n\r\nNow you can click on the image below for a new window! \r\n\r\n \r\n\r\nThe second way to do this is a little more difficult, but some people may be more comfortable with it. The trick is to go ahead and use the onClick=\" \" attribute in your link tag. The trick here is to keep the browser from following the actual link after running your script. Here is a sample of using the onClick attribute in the link tag: \r\n\r\n<A HREF=\"newpage.htm\" onClick=\"newwindow();return false\">Click Here!</A> \r\n\r\nI used the same script we had written in the head section for the first method, but I used it inside the onClick=\" \" command. Also notice the semicolon after the function call, and the \"return false\" at the end of the command. The return false part keeps the browser from going to \"newpage.htm\" after opening your new window. You could put any page here you want, and the link will no longer take you there (except in some older browsers). So you don\'t really have to put an actual url in the HREF attribute here unless you wish to offer an alternative for those with older browsers that don\'t recognize the onClick=\" \" command. As in the above example, you can also use an image inside your link tag to make a clickable image. Below is an example link where I used this second method: \r\n\r\nClick Here! \r\n\r\nWell, that about does it for now......The next section is a Congratulations Section! \r\n\r\n\r\n\r\n--------------------------------------------------------------------------------\r\nPartners \r\n--------------------------------------------------------------------------------\r\nCoolHomepages | Web Design Library | Website Content\r\n\r\n--------------------------------------------------------------------------------\r\nThe tutorials and articles on these pages are Â© 1997-2007 by John Pollock and may not be reposted without written permission from the author, and may not be reprinted for profit. Disclaimer. \r\n--------------------------------------------------------------------------------\r\n    \r\n\r\n\r\n\r\n \r\n\r\nPrevious  By: John Pollock   \r\n\r\nNext  \r\n\r\n\r\n\r\n--------------------------------------------------------------------------------\r\nMain Page  |  HTML  |  JavaScript  |  Graphics  |  DHTML/Style Sheets  |  ASP/PHP \r\nPutWeb/FTP  |  CGI/Perl  |  Promotion  |  Java  |  Design Articles \r\nSupport Forums  |  Site Search  |  FAQs  |  Privacy  |  Contact \r\n--------------------------------------------------------------------------------\r\n\r\nCopyright Â© 1997-2007 The Web Design Resource. All rights reserved. Disclaimer. ','2008-01-13 22:26:05','2008-01-13 22:26:05',1,NULL,1);
INSERT INTO ideas VALUES (7,2,2,NULL,'Amptjer odea','Pme\r\nOne\r\ntwo\r\nthree\r\nfour\r\none more','2008-01-13 22:48:14','2008-01-13 22:48:47',3,NULL,3);
INSERT INTO ideas VALUES (8,2,1,NULL,'Another idea and yet one more','helloand goodbye','2008-01-13 22:49:20','2008-01-13 22:49:20',1,NULL,1);
INSERT INTO ideas VALUES (9,2,3,NULL,'again','yep','2008-01-13 22:49:37','2008-01-13 22:49:37',1,NULL,1);
INSERT INTO ideas VALUES (10,2,4,NULL,';lkjas;dfja;sdkfj;a',';jsakdf\r\nasdf\r\na\r\n\r\n\r\nas\r\nd\r\n\r\n\r\na\r\nsdf\r\na\r\n\r\n\r\ngsdaf\r\nasdf\r\n\r\nasddfas;kjas;dfja\r\n\r\nads\r\n','2008-01-13 22:49:56','2008-01-13 22:49:56',1,NULL,1);
INSERT INTO ideas VALUES (11,
                            2,
                            4,
                            NULL,
                            'This is a test of this or that',
                            'This is the body of the idea',
                            '2008-01-13 22:49:56','2008-01-13 22:49:56',1,NULL,1);

--
-- Table structure for table lookup_codes
--
drop table if exists lookup_codes ;

CREATE TABLE lookup_codes (
  id int(11) NOT NULL auto_increment,
  code_type varchar(30) NOT NULL,
  short_name varchar(20) NOT NULL,
  description varchar(50) NOT NULL,
  sort_value int(11) NOT NULL default '100',
  created_at datetime NOT NULL,
  lock_version int(11) default '0',
  PRIMARY KEY  (id),
  KEY index_lookup_codes_on_code_type_and_short_name (code_type,short_name)
);

--
-- Dumping data for table lookup_codes
--

INSERT INTO lookup_codes VALUES (1,'ReleaseStatus','Released','Released',30,'2008-01-03 23:12:59',0);
INSERT INTO lookup_codes VALUES (2,'ReleaseStatus','InProgress','In Progress',20,'2008-01-03 23:12:59',0);
INSERT INTO lookup_codes VALUES (3,'ReleaseStatus','Planned','Planned',10,'2008-01-03 23:12:59',0);

--
-- Table structure for table products
--

drop table if exists products ;


CREATE TABLE products (
  id int(11) NOT NULL auto_increment,
  name varchar(30) NOT NULL,
  description varchar(200) NOT NULL,
  active tinyint(1) NOT NULL default '1',
  created_at datetime NOT NULL,
  lock_version int(11) default '0',
  PRIMARY KEY  (id),
  UNIQUE KEY index_products_on_name (name)
);

--
-- Dumping data for table products
--

INSERT INTO products VALUES (1,'Microsoft Dynamics GP Adapter','Adapter for Great Plains Accounting & ERP solution',1,'2008-01-04 10:55:37',1);
INSERT INTO products VALUES (2,'Insight','Scribe Insight',1,'2008-01-04 10:55:37',0);
INSERT INTO products VALUES (3,'Microsofts Dynamics AX','Adapter for AX ERP System',1,'2008-01-13 22:10:28',1);
INSERT INTO products VALUES (4,'AX-GP Template','Dynamics AX to Dynamics GP',1,'2008-01-13 22:15:21',0);

--
-- Table structure for table releases
--
drop table if exists releases ;

CREATE TABLE releases (
  id int(11) NOT NULL auto_increment,
  version varchar(20) NOT NULL,
  product_id int(11) NOT NULL,
  release_status_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  lock_version int(11) default '0',
  PRIMARY KEY  (id),
  UNIQUE KEY index_releases_on_product_id_and_version (product_id,version),
  KEY index_releases_on_product_id (product_id)
);

--
-- Dumping data for table releases
--

INSERT INTO releases VALUES (1,'1.0',2,1,'2008-01-04 11:08:40',0);
INSERT INTO releases VALUES (2,'2.0',2,3,'2008-01-04 11:08:50',0);
INSERT INTO releases VALUES (3,'1.1',1,3,'2008-01-07 20:47:54',0);
INSERT INTO releases VALUES (4,'1.0',1,3,'2008-01-07 20:58:22',0);
INSERT INTO releases VALUES (5,'1.0',3,1,'2008-01-13 22:14:32',0);
INSERT INTO releases VALUES (6,'1.1',3,2,'2008-01-13 22:14:41',0);
INSERT INTO releases VALUES (7,'2.0',3,3,'2008-01-13 22:14:48',0);

--
-- Table structure for table roles
--
drop table if exists roles ;

CREATE TABLE roles (
  id int(11) NOT NULL auto_increment,
  title varchar(50) NOT NULL,
  description varchar(50) NOT NULL,
  default_role tinyint(1) default '0',
  lock_version int(11) default '0',
  created_at datetime NOT NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY index_roles_on_title (title)
);

--
-- Dumping data for table roles
--

INSERT INTO roles VALUES (1,'sysadmin','System Admininistrator',0,0,'2008-01-03 23:13:06');
INSERT INTO roles VALUES (2,'prodmgr','Product Manager',0,0,'2008-01-03 23:13:06');
INSERT INTO roles VALUES (3,'voter','Voter',1,0,'2008-01-03 23:13:06');
INSERT INTO roles VALUES (4,'allocmgr','Allocations Manager',0,0,'2008-01-03 23:13:06');

--
-- Table structure for table roles_users
--
drop table if exists roles_users ;

CREATE TABLE roles_users (
  user_id int(11) NOT NULL,
  role_id int(11) NOT NULL,
  lock_version int(11) default '0',
  created_at datetime NOT NULL,
  KEY index_roles_users_on_user_id (user_id),
  KEY index_roles_users_on_role_id (role_id)
);

--
-- Dumping data for table roles_users
--

INSERT INTO roles_users VALUES (1,1,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (2,2,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (3,3,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (5,4,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (6,1,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (6,2,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (6,3,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (6,4,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (7,3,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (7,1,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (7,2,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (7,4,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (8,1,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (8,2,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (8,3,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (8,4,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (9,1,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (9,2,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (9,3,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (9,4,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (10,4,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (11,3,0,'2008-01-03 23:13:06');
INSERT INTO roles_users VALUES (12,3,0,'2008-01-03 23:13:06');

--
-- Table structure for table schema_info
--
drop table if exists schema_info ;

CREATE TABLE schema_info (
  version int(11) default NULL
);

--
-- Dumping data for table schema_info
--

INSERT INTO schema_info VALUES (30);

--
-- Table structure for table sessions
--
drop table if exists sessions ;

CREATE TABLE sessions (
  id int(11) NOT NULL auto_increment,
  session_id varchar(255) default NULL,
  data text,
  updated_at datetime default NULL,
  PRIMARY KEY  (id),
  KEY index_sessions_on_session_id (session_id),
  KEY index_sessions_on_updated_at (updated_at)
);

--
-- Dumping data for table sessions
--


--
-- Table structure for table user_idea_reads
--
drop table if exists user_idea_reads ;

CREATE TABLE user_idea_reads (
  id int(11) NOT NULL auto_increment,
  user_id int(11) NOT NULL,
  idea_id int(11) NOT NULL,
  last_read datetime NOT NULL default '2008-01-03 23:13:06',
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  lock_version int(11) default '0',
  PRIMARY KEY  (id),
  KEY index_user_idea_reads_on_user_id (user_id),
  KEY index_user_idea_reads_on_idea_id (idea_id)
);

--
-- Dumping data for table user_idea_reads
--

INSERT INTO user_idea_reads VALUES (1,6,1,'2008-01-09 00:45:53','2008-01-04 10:58:53','2008-01-09 00:45:53',9);
INSERT INTO user_idea_reads VALUES (2,6,2,'2008-01-09 00:30:15','2008-01-04 10:59:11','2008-01-09 00:30:15',3);
INSERT INTO user_idea_reads VALUES (3,9,3,'2008-01-04 11:21:34','2008-01-04 10:59:44','2008-01-04 11:21:34',3);
INSERT INTO user_idea_reads VALUES (4,6,3,'2008-01-04 11:10:02','2008-01-04 11:03:41','2008-01-04 11:10:02',4);
INSERT INTO user_idea_reads VALUES (5,9,2,'2008-01-04 11:05:32','2008-01-04 11:05:21','2008-01-04 11:05:32',1);
INSERT INTO user_idea_reads VALUES (6,9,1,'2008-01-04 11:25:33','2008-01-04 11:19:02','2008-01-04 11:25:33',3);
INSERT INTO user_idea_reads VALUES (7,8,4,'2008-01-04 11:19:46','2008-01-04 11:19:05','2008-01-04 11:19:46',1);
INSERT INTO user_idea_reads VALUES (8,9,4,'2008-01-04 11:24:32','2008-01-04 11:19:18','2008-01-04 11:24:32',6);
INSERT INTO user_idea_reads VALUES (9,8,1,'2008-01-04 11:19:26','2008-01-04 11:19:19','2008-01-04 11:19:26',1);
INSERT INTO user_idea_reads VALUES (10,6,4,'2008-01-11 16:33:56','2008-01-07 20:19:41','2008-01-11 16:33:56',33);
INSERT INTO user_idea_reads VALUES (11,11,4,'2008-01-11 16:42:46','2008-01-11 16:42:46','2008-01-11 16:42:46',0);
INSERT INTO user_idea_reads VALUES (12,12,4,'2008-01-13 22:25:29','2008-01-13 22:23:07','2008-01-13 22:25:29',1);
INSERT INTO user_idea_reads VALUES (13,12,5,'2008-01-13 22:25:15','2008-01-13 22:25:15','2008-01-13 22:25:15',0);
INSERT INTO user_idea_reads VALUES (14,12,6,'2008-01-13 22:26:05','2008-01-13 22:26:05','2008-01-13 22:26:05',0);
INSERT INTO user_idea_reads VALUES (15,2,4,'2008-01-13 22:46:21','2008-01-13 22:46:21','2008-01-13 22:46:21',0);
INSERT INTO user_idea_reads VALUES (16,2,7,'2008-01-13 22:48:47','2008-01-13 22:48:14','2008-01-13 22:48:47',2);
INSERT INTO user_idea_reads VALUES (17,2,8,'2008-01-13 22:49:20','2008-01-13 22:49:20','2008-01-13 22:49:20',0);
INSERT INTO user_idea_reads VALUES (18,2,9,'2008-01-13 22:49:37','2008-01-13 22:49:37','2008-01-13 22:49:37',0);
INSERT INTO user_idea_reads VALUES (19,2,10,'2008-01-13 22:49:56','2008-01-13 22:49:56','2008-01-13 22:49:56',0);
INSERT INTO user_idea_reads VALUES (20,2,11,'2008-01-13 22:50:53','2008-01-13 22:50:45','2008-01-13 22:50:53',1);

--
-- Table structure for table user_logons
--
drop table if exists user_logons ;

CREATE TABLE user_logons (
  id int(11) NOT NULL auto_increment,
  user_id int(11) NOT NULL,
  lock_version int(11) default '0',
  created_at datetime NOT NULL,
  PRIMARY KEY  (id),
  KEY index_user_logons_on_created_at (created_at),
  KEY index_user_logons_on_user_id (user_id)
);

--
-- Dumping data for table user_logons
--

INSERT INTO user_logons VALUES (1,1,0,'2008-01-04 07:39:34');
INSERT INTO user_logons VALUES (2,2,0,'2008-01-04 07:53:42');
INSERT INTO user_logons VALUES (3,1,0,'2008-01-04 07:54:45');
INSERT INTO user_logons VALUES (4,1,0,'2008-01-04 10:48:09');
INSERT INTO user_logons VALUES (5,9,0,'2008-01-04 10:52:10');
INSERT INTO user_logons VALUES (6,6,0,'2008-01-04 10:53:02');
INSERT INTO user_logons VALUES (7,8,0,'2008-01-04 11:18:04');
INSERT INTO user_logons VALUES (8,3,0,'2008-01-05 09:16:06');
INSERT INTO user_logons VALUES (9,3,0,'2008-01-05 20:36:17');
INSERT INTO user_logons VALUES (10,6,0,'2008-01-05 20:42:55');
INSERT INTO user_logons VALUES (11,2,0,'2008-01-05 20:46:11');
INSERT INTO user_logons VALUES (12,6,0,'2008-01-05 20:47:14');
INSERT INTO user_logons VALUES (13,6,0,'2008-01-05 20:56:08');
INSERT INTO user_logons VALUES (14,5,0,'2008-01-06 20:52:13');
INSERT INTO user_logons VALUES (15,6,0,'2008-01-07 20:18:26');
INSERT INTO user_logons VALUES (16,6,0,'2008-01-07 20:36:11');
INSERT INTO user_logons VALUES (17,6,0,'2008-01-07 20:36:27');
INSERT INTO user_logons VALUES (18,6,0,'2008-01-08 21:01:30');
INSERT INTO user_logons VALUES (19,6,0,'2008-01-08 21:03:33');
INSERT INTO user_logons VALUES (20,11,0,'2008-01-08 21:35:22');
INSERT INTO user_logons VALUES (21,6,0,'2008-01-08 21:42:18');
INSERT INTO user_logons VALUES (22,6,0,'2008-01-08 21:43:57');
INSERT INTO user_logons VALUES (23,6,0,'2008-01-08 21:45:19');
INSERT INTO user_logons VALUES (24,6,0,'2008-01-08 22:10:27');
INSERT INTO user_logons VALUES (25,6,0,'2008-01-08 22:11:28');
INSERT INTO user_logons VALUES (26,6,0,'2008-01-08 22:12:52');
INSERT INTO user_logons VALUES (27,11,0,'2008-01-08 22:45:24');
INSERT INTO user_logons VALUES (28,6,0,'2008-01-08 22:48:19');
INSERT INTO user_logons VALUES (29,6,0,'2008-01-10 20:32:11');
INSERT INTO user_logons VALUES (30,6,0,'2008-01-11 16:33:40');
INSERT INTO user_logons VALUES (31,11,0,'2008-01-11 16:42:45');
INSERT INTO user_logons VALUES (32,6,0,'2008-01-11 16:44:57');
INSERT INTO user_logons VALUES (33,1,0,'2008-01-11 21:02:06');
INSERT INTO user_logons VALUES (34,4,0,'2008-01-11 21:39:13');
INSERT INTO user_logons VALUES (35,1,0,'2008-01-11 21:40:48');
INSERT INTO user_logons VALUES (36,6,0,'2008-01-13 20:35:21');
INSERT INTO user_logons VALUES (37,6,0,'2008-01-13 20:51:57');
INSERT INTO user_logons VALUES (38,6,0,'2008-01-13 22:13:52');
INSERT INTO user_logons VALUES (39,6,0,'2008-01-13 22:19:38');
INSERT INTO user_logons VALUES (40,12,0,'2008-01-13 22:22:40');
INSERT INTO user_logons VALUES (41,2,0,'2008-01-13 22:46:06');

--
-- Table structure for table users
--
drop table if exists users ;

CREATE TABLE users (
  id int(11) NOT NULL auto_increment,
  email varchar(255) default NULL,
  crypted_password varchar(40) default NULL,
  salt varchar(40) default NULL,
  created_at datetime default NULL,
  updated_at datetime default NULL,
  remember_token varchar(255) default NULL,
  remember_token_expires_at datetime default NULL,
  first_name varchar(255) default NULL,
  last_name varchar(255) default NULL,
  row_limit int(11) NOT NULL default '10',
  active tinyint(1) NOT NULL default '1',
  lock_version int(11) default '0',
  activation_code varchar(40) default NULL,
  activated_at datetime default NULL,
  last_message_read datetime default NULL,
  enterprise_id int(11) NOT NULL,
  time_zone varchar(255) default 'Eastern Time (US & Canada)',
  force_change_password tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (id),
  UNIQUE KEY index_users_on_email (email)
);

--
-- Dumping data for table users
--

INSERT INTO users VALUES (1,'admin@openmind.org','9eb8a17adeee5e810f310ef43f1829a4b7cc3b9b','735d08a3b3f6599b97bd246f2fd2d7f73ca9c004','2008-01-03 23:12:59','2008-01-13 22:13:47',NULL,NULL,NULL,'Admin',10,1,40,'17821f8e09b3e505ec84932e2c64ff2283b06ba6','2008-01-03 23:13:05','2008-01-13 21:58:27',1,'Eastern Time (US & Canada)',0);
INSERT INTO users VALUES (2,'prodmgr@openmind.org','dbcb8b2b3446e908ea15306b6aa6955b5c8ca6ce','2933434009d4a3e4c9ae0d0313d7a01c086b39f4','2008-01-03 23:13:00','2008-01-05 20:47:09',NULL,NULL,NULL,'ProdMgr',10,1,6,'63c8c39bf62fe91587fa14ac8ec541a2e332763e','2008-01-03 23:13:05',NULL,1,'Eastern Time (US & Canada)',0);
INSERT INTO users VALUES (3,'voter@openmind.org','4cc97d70ad0544fda67ba5657dbc452d67f91b02','184acf0e13cf2e950866082678bdbf4d13d3dad7','2008-01-03 23:13:01','2008-01-13 22:20:32',NULL,NULL,'','Voter',10,1,6,'7920430df92fb53c787846f01c4bd1e488c80ca1',NULL,NULL,1,'Eastern Time (US & Canada)',1);
INSERT INTO users VALUES (4,'readonly@openmind.org','93e5da246461abf796abf8694cae8620180ec321','5d5013f19caf220c3ecb2686955e56ece4df2248','2008-01-03 23:13:02','2008-01-11 21:40:20',NULL,NULL,NULL,'ReadOnly',10,1,4,'047bcfe0fafcd0d22f4d435132bc95bcf103021a','2008-01-03 23:13:05','2008-01-11 21:39:45',1,'Eastern Time (US & Canada)',0);
INSERT INTO users VALUES (5,'allocmgr@openmind.org','5a780ab86ce45930f2c96ff41d0d4f0a20a0754f','7eb1b1f43866885edd1a06b1315cc7970d7fd9aa','2008-01-03 23:13:03','2008-01-06 20:52:31',NULL,NULL,NULL,'AllocMgr',10,1,4,'3eec72f1499b5478a3554af527086105a836b66a','2008-01-03 23:13:05',NULL,1,'Eastern Time (US & Canada)',0);
INSERT INTO users VALUES (6,'all@openmind.org','92656309afd02cb3611a62ef34fffd6f5a6b5adb','bf8b6268488c9736e47e76d54f9fa38be489c9bf','2008-01-03 23:13:04','2008-01-13 22:20:49',NULL,NULL,'','All',10,1,42,'6f1ada8d362727712679e20e6e9220b1bb5d41d5','2008-01-03 23:13:05','2008-01-13 21:57:46',1,'Eastern Time (US & Canada)',0);
INSERT INTO users VALUES (7,'bsturim@scribesoftware.com','e59c07e9fcb061032b2fc6cb9df49760568bb397','40376150b09904cdec2f01fba7e6f9b2f34a9065','2008-01-04 07:55:40','2008-01-04 07:55:58',NULL,NULL,'Bob','Sturim',10,1,1,'773a17af5197399ddc45bac388aeb2a560c92e6c',NULL,NULL,1,'Eastern Time (US & Canada)',1);
INSERT INTO users VALUES (8,'mwalker@scribesoft.com','a2f56fa2a2aa88091e10175370eadd16bed6e954','0c8c853e3ae860d004fd8cd92c0e43d073b9566f','2008-01-04 10:49:24','2008-01-04 11:28:06',NULL,NULL,'Mark','Walker',100,1,8,NULL,'2008-01-04 11:17:23',NULL,2,'Eastern Time (US & Canada)',0);
INSERT INTO users VALUES (9,'tobrien@scribesoft.com','892dd3aa5ccdff5ce14926e29959f64c3ad5d27b','a2055183fac4b4932551a6d551be91ce0138e512','2008-01-04 10:50:52','2008-01-04 10:52:24',NULL,NULL,'Tom','O\'Brien',10,1,4,NULL,'2008-01-04 10:51:43',NULL,2,'Pacific Time (US & Canada)',0);
INSERT INTO users VALUES (10,'joe@sturim.org','b01e3214daeba2360a30719e6cd93814460af31d','36b141ab074daf5362699f77f52739c113445438','2008-01-06 20:47:25','2008-01-13 20:21:57',NULL,NULL,'Joe','Sturim',10,1,1,'2c397eef23fa679f3f411d45a91040ee448aefe1',NULL,NULL,1,'Eastern Time (US & Canada)',1);
INSERT INTO users VALUES (11,'voter@sturim.org','b3ac5147d4e0b70ab2b8d62af9137ffc68e3c9d3','7cc13bd74781b9f74a9b9643e60ed2d463005b46','2008-01-08 21:26:14','2008-01-11 16:44:51',NULL,NULL,'voter','sturim',10,1,10,NULL,'2008-01-08 21:34:42','2008-01-11 16:43:26',1,'Eastern Time (US & Canada)',0);
INSERT INTO users VALUES (12,'rick@sturim.org','c6d4edffca1299b7528e5715f49a9f602b41c11b','c9265aafbb5217e40d6a2abf4a32693ddb4a25e6','2008-01-13 22:17:59','2008-01-13 22:45:57',NULL,NULL,'Rick','Sturim',10,1,5,NULL,'2008-01-13 22:22:02',NULL,9,'Eastern Time (US & Canada)',0);

--
-- Table structure for table votes
--
drop table if exists votes ;

CREATE TABLE votes (
  id int(11) NOT NULL auto_increment,
  user_id int(11) NOT NULL,
  allocation_id int(11) default NULL,
  idea_id int(11) default NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  lock_version int(11) default '0',
  comments text,
  PRIMARY KEY  (id),
  KEY index_votes_on_user_id (user_id),
  KEY index_votes_on_allocation_id (allocation_id),
  KEY index_votes_on_idea_id (idea_id)
);

--
-- Dumping data for table votes
--

INSERT INTO votes VALUES (1,6,5,3,'2008-01-04 11:03:46','2008-01-04 11:03:46',0,NULL);
INSERT INTO votes VALUES (2,9,1,1,'2008-01-04 11:05:20','2008-01-04 11:11:05',1,'Reassigned from idea number 2 to idea number 1');
INSERT INTO votes VALUES (3,9,1,3,'2008-01-04 11:06:16','2008-01-04 11:06:16',0,NULL);
INSERT INTO votes VALUES (4,8,8,1,'2008-01-04 11:19:18','2008-01-04 11:19:18',0,NULL);
INSERT INTO votes VALUES (5,8,8,1,'2008-01-04 11:19:25','2008-01-04 11:19:25',0,NULL);
INSERT INTO votes VALUES (6,8,8,4,'2008-01-04 11:19:44','2008-01-04 11:19:44',0,NULL);
INSERT INTO votes VALUES (7,9,1,4,'2008-01-04 11:19:45','2008-01-04 11:19:45',0,NULL);
INSERT INTO votes VALUES (8,9,1,1,'2008-01-04 11:23:51','2008-01-04 11:23:51',0,NULL);
INSERT INTO votes VALUES (9,9,1,4,'2008-01-04 11:24:02','2008-01-04 11:24:02',0,NULL);
INSERT INTO votes VALUES (10,9,1,4,'2008-01-04 11:24:25','2008-01-04 11:24:25',0,NULL);
INSERT INTO votes VALUES (11,9,1,4,'2008-01-04 11:24:31','2008-01-04 11:24:31',0,NULL);
INSERT INTO votes VALUES (12,9,11,1,'2008-01-04 11:25:26','2008-01-04 11:25:26',0,NULL);
INSERT INTO votes VALUES (13,9,3,1,'2008-01-04 11:25:32','2008-01-04 11:25:32',0,NULL);

--
-- Table structure for table watches
--
drop table if exists watches ;

CREATE TABLE watches (
  user_id int(11) NOT NULL,
  idea_id int(11) NOT NULL,
  lock_version int(11) default '0',
  created_at datetime NOT NULL,
  KEY index_watches_on_user_id (user_id),
  KEY index_watches_on_idea_id (idea_id)
);

--
-- Dumping data for table watches
--

INSERT INTO watches VALUES (6,3,5,'2008-01-03 23:13:04');
INSERT INTO watches VALUES (9,4,4,'2008-01-04 10:50:52');
INSERT INTO watches VALUES (6,4,19,'2008-01-03 23:13:04');
INSERT INTO watches VALUES (12,4,4,'2008-01-13 22:17:59');

-- Dump completed on 2008-01-14  4:03:57