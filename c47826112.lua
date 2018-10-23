--海皇龍 ポセイドラ
function c47826112.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47826112,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCost(c47826112.spcost)
	e1:SetTarget(c47826112.sptg)
	e1:SetOperation(c47826112.spop)
	c:RegisterEffect(e1)
	--return
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47826112,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c47826112.thcon)
	e2:SetTarget(c47826112.thtg)
	e2:SetOperation(c47826112.thop)
	c:RegisterEffect(e2)
end
function c47826112.cfilter(c,tp)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and (c:IsControler(tp) or c:IsFaceup())
end
function c47826112.fselect(c,tp,rg,sg)
	sg:AddCard(c)
	if sg:GetCount()<3 then
		res=rg:IsExists(c47826112.fselect,1,sg,tp,rg,sg)
	else
		res=c47826112.fgoal(tp,sg)
	end
	sg:RemoveCard(c)
	return res
end
function c47826112.fgoal(tp,sg)
	if sg:GetCount()>0 and Duel.GetMZoneCount(tp,sg)>0 then
		Duel.SetSelectedCard(sg)
		return Duel.CheckReleaseGroup(tp,nil,0,nil)
	else return false end
end
function c47826112.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetReleaseGroup(tp):Filter(c47826112.cfilter,nil,tp)
	local g=Group.CreateGroup()
	if chk==0 then return rg:IsExists(c47826112.fselect,1,nil,tp,rg,g) end
	while g:GetCount()<3 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=rg:FilterSelect(tp,c47826112.fselect,1,1,g,tp,rg,g)
		g:Merge(sg)
	end
	Duel.Release(g,REASON_COST)
end
function c47826112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c47826112.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
end
function c47826112.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function c47826112.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c47826112.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(c47826112.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function c47826112.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c47826112.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	if ct>=3 then
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=mg:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-ct*300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=mg:GetNext()
		end
	end
end
