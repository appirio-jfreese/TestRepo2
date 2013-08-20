<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Agency_Name_Sharing_Rule</fullName>
        <field>Agency_Name_Sharing_Rule__c</field>
        <formula>Agency_Name__c</formula>
        <name>Update Agency Name (Sharing Rule)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Current_Price</fullName>
        <description>Updates the Current Price value with the Estimated Price value</description>
        <field>Current_Price__c</field>
        <formula>Estimated_Price__c</formula>
        <name>Update Current Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_RecordType_Name</fullName>
        <description>Updates the RecordType Name</description>
        <field>RecordType_Name__c</field>
        <formula>$RecordType.Name</formula>
        <name>Update RecordType Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>POS%3A Update Agency Name</fullName>
        <actions>
            <name>Update_Agency_Name_Sharing_Rule</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Item__c.OwnerId</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <description>Updates the &quot;Agency Name (Sharing)&quot; field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>POS%3A Update Current Price</fullName>
        <actions>
            <name>Update_Current_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates an Item&apos;s current price with the estimated price value when the Item&apos;s status changes to &quot;Accepted w/Final Price&quot;</description>
        <formula>ISCHANGED(Status__c) &amp;&amp; ISPICKVAL(Status__c, &quot;Accepted w/Final Price&quot;) &amp;&amp;  NOT(ISPICKVAL(PRIORVALUE(Status__c), &quot;Accepted w/Final Price&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update RecordType Name</fullName>
        <actions>
            <name>Update_RecordType_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the RecordType name so it can be accessed from Cart Items</description>
        <formula>NOT(ISBLANK(CreatedDate))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
