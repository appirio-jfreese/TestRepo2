<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Record_Type_Name_for_Calendar</fullName>
        <description>Set&apos;s the record type name on the Calendar object as part of the S2S Integration process.</description>
        <field>Record_Type_Name__c</field>
        <formula>RecordTypeId</formula>
        <name>Set Record Type Name for Calendar</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Record Type Name field for S2S Integration</fullName>
        <actions>
            <name>Set_Record_Type_Name_for_Calendar</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Calendar__c.Record_Type_Name__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
