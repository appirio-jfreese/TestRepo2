<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_of_Recipe_Publication_Approval</fullName>
        <description>Notification of Recipe Publication Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Recipe_Approved_For_Publication</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_Rejection</fullName>
        <description>Notification of Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Recipe_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_Rejection_By_Approver</fullName>
        <description>Notification of Rejection By Approver</description>
        <protected>false</protected>
        <recipients>
            <field>ReviewedBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Recipe_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_Reviewer_Approval</fullName>
        <description>Notification of Reviewer Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Recipe_Approved</template>
    </alerts>
    <fieldUpdates>
        <fullName>Edit_Notification_Recipe</fullName>
        <field>Edit_Notification_To_Publisher__c</field>
        <literalValue>1</literalValue>
        <name>Edit Notification - Recipe</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Recipe_Status_Update_To_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Recipe Status Update To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Recipe_Status_Update_To_Pending_Approver</fullName>
        <field>Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Recipe Status Update To Pending Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Recipe_Status_Update_To_Pending_Reviewer</fullName>
        <field>Status__c</field>
        <literalValue>Pending Review</literalValue>
        <name>Recipe Status Update To Pending Reviewer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Recipe_Status_Update_to_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Recipe Status Update to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Approved Recipe Edit Notification To Publisher - Recipe</fullName>
        <actions>
            <name>Edit_Notification_Recipe</name>
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
