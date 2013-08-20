<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>POS_Send_Submitted_Email_Confirmation</fullName>
        <ccEmails>pos-order-confirmation@diageo.com</ccEmails>
        <description>POS: Send Submitted Email Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Shopper__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>pos-order-confirmation@diageo.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/POS_Submitted_Order_Confirmation</template>
    </alerts>
    <rules>
        <fullName>POS%3A Send Submitted Order Confirmation Email</fullName>
        <actions>
            <name>POS_Send_Submitted_Email_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends a confirmation email to a shopper when an order is submitted</description>
        <formula>ISCHANGED(Last_Submitted__c) &amp;&amp; ISPICKVAL(Status__c, &quot;Submitted&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Submitted Order Confirmation Email</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Cart__c.Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>Sends a confirmation email to a shopper when an order is submitted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
