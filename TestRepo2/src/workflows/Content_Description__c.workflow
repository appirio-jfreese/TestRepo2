<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Video_share_link</fullName>
        <field>share_link__c</field>
        <formula>&quot;http://diageodirect.force.com/apex/Preview?videoId=&quot;+ Video_Id__c</formula>
        <name>Video share link</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>new_content_uploaded</fullName>
        <apiVersion>23.0</apiVersion>
        <endpointUrl>http://pa.diageodirect.com/prod/CDIn.php</endpointUrl>
        <fields>Content_ID_Low__c</fields>
        <fields>Content_ID__c</fields>
        <fields>Content_Version_Id_Low__c</fields>
        <fields>Content_Version_Id__c</fields>
        <fields>Description__c</fields>
        <fields>Id</fields>
        <fields>Title__c</fields>
        <fields>filetype__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>previewuser@previewuser.prod</integrationUser>
        <name>new content uploaded</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>new content uploaded</fullName>
        <actions>
            <name>new_content_uploaded</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>new content uploaded</description>
        <formula>(ISCHANGED( Content_Version_Id__c ) || ISCHANGED( Content_Version_Id_Low__c) || ISNEW() ) &amp;&amp; filetype__c !=&apos;Video&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>share link</fullName>
        <actions>
            <name>Video_share_link</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>share link</description>
        <formula>Is_Video__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
