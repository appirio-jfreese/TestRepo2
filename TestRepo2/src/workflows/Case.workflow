<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Dev_Support_Team</fullName>
        <ccEmails>b.dudziak@polsource.com</ccEmails>
        <ccEmails>m.malik@polsource.com</ccEmails>
        <ccEmails>m.krol@polsource.com</ccEmails>
        <ccEmails>w.migas@polsoure.com</ccEmails>
        <description>Notify Dev Support Team</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SUPPORT_New_case_assignment_notification</template>
    </alerts>
    <rules>
        <fullName>Notify Dev Support Team</fullName>
        <actions>
            <name>Notify_Dev_Support_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(Notify_Dev_Support_Team__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
