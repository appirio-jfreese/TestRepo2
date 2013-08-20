<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Edit_Notification_Preparation_Step</fullName>
        <field>Edit_Notification_To_Publisher__c</field>
        <literalValue>1</literalValue>
        <name>Edit Notification - Preparation Step</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Recipe__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Approved Recipe Edit Notification To Publisher - Preparation Step</fullName>
        <actions>
            <name>Edit_Notification_Preparation_Step</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Recipe__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>Recipe - Admin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Recipe__c.Edit_Notification_To_Publisher__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
