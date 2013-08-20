public class TriggerAccountTeamMemberHandler {
    public class insertException extends Exception {}
    public static Boolean isBlocked = false;
    public static void beforeUpdateOrInsert(List<Account_Member__c> newMembers, List<Account_Member__c> oldMembers){
        if(isBlocked)
            return;
        //check unique default in this batch
        Set<Id> uidsDef = new Set<Id>();
        for(Account_Member__c m : newMembers){
            if(m.Default__c){
                if(!m.Active__c){
                    m.addError('Cannot inactivate the default account. Set another account as default.');
                    return;
                }
                if(uidsDef.contains(m.User__c)){
                    m.addError('Duplicate default accounts in one batch.');
                    return;
                }
                uidsDef.add(m.User__c);
            }
        }
        //remove inactive from team
        List<Id> teamIds = new List<Id>();
        for(Account_Member__c m : newMembers){
            if((!m.Active__c) && (m.AccountTeamId__c != null && m.AccountTeamId__c != '')){
                teamIds.add(m.AccountTeamId__c);
                m.AccOuntTeamId__c = '';
            }
        }
        if(!teamIds.isEmpty()){
            List<AccountTeamMember> teams = [select Id from AccountTeamMember where id in :teamIds];
            if(!teams.isEmpty())
                delete teams;
        }
        //activate back - add team
        List<Account_Member__c> membersToAddToTeam = new List<Account_Member__c>();
         for(Account_Member__c m : newMembers){
            if((m.Active__c) && (m.AccountTeamId__c == null || m.AccountTeamId__c == '')){
                membersToAddToTeam.add(m);
            }
        }
        if(!membersToAddToTeam.isEmpty()){
            beforeInsert(membersToAddToTeam, null);
        }
        //check unique default
        List<Id> active = new List<Id>();
        for(Account_Member__c m : newMembers){
            if(m.Default__c){
                active.add(m.User__c);
            }
        }
        if(!active.isEmpty()){
            List<Account_Member__c> conf = [select Id, User__c from Account_Member__c where User__c in :active and Default__c = true];
            for(Account_Member__c c : conf){
                c.Default__c = false;
            }
            isBlocked = true;
            update conf;
            isblocked = false;
        }
        List<Account_Member__c> mem = new List<Account_Member__c>();
        List<Id> mids = new List<Id>();
        List<Id> uids = new List<Id>();
        Set<Id> correct = new Set<Id>();
        for(Account_Member__c m : newMembers){
            if(!m.Default__c){
                mem.add(m);
                uids.add(m.User__c);
                mids.add(m.id);
            }
        }
        if(!mem.isEmpty()){
            List<Account_Member__c> act = [select User__c from Account_Member__c where Default__c = true and User__c in :uids and Id not in :mids];
            for(Account_Member__c m : act){
                correct.add(m.User__c);
            }
            for(Id uid : uids){
                if(!correct.contains(uid)){
                    for(Account_Member__c m : mem){
                        if(m.User__c == uid){
                            m.Default__c = true;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    public static void afterDelete(List<Account_Member__c> newMembers, List<Account_Member__c> oldMembers){
        Boolean error = false;
        for(Account_Member__c m : oldMembers){
            if(m.Default__c){
                m.addError('Cannot remove default account. Make some other account default.');
                error = true;
                break;
            }
        }
        if(!error){
            List<String> ids = new List<String>();
            for(Account_Member__c member : oldMembers){
                ids.add(member.AccountTeamId__c);
            }
            List<AccountTeamMember> team = [select Id from AccountTeamMember where Id in :ids];
            delete team;
        }
    } 
    
    public static void beforeInsert(List<Account_Member__c> newMembers, List<Account_Member__c> oldMembers){
        List<Account_Member__c> members = newMembers;
        List<AccountTeamMember> team = new List<AccountTeamMember>();
        for(Account_Member__c member : newMembers){
            system.debug('e');
            AccountTeamMember tmp = new AccountTeamMember(AccountId = member.Account__c, UserId = member.User__c, TeamMemberRole = 'Account Manager');
            team.add(tmp);
        }
        insert team;
        for(Integer i=0; i<team.size(); i++){
            members.get(i).AccountTeamId__c = team.get(i).id;
        }
    } 
}