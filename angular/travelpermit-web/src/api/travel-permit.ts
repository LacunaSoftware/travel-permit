import { BioDocumentType, BioGender, LegalGuardianTypes, TravelPermitTypes, Uf } from "./enums";

export interface TravelPermitOfflineModel {
	version: number;
	key: string;
	startDate?: string;
	expirationDate: string;
	type: string;
	requiredGuardian: GuardianOfflineModel;
	optionalGuardian: GuardianOfflineModel;
	escort: EscortOfflineModel;
	underage: UnderageOfflineModel;
	judge: JudgeOfflineModel;
	organization: OrganizationOfflineModel;
	signature: string;
}

export interface JudgeOfflineModel {
	name: string;
}

export interface OrganizationOfflineModel {
	name: string;
}

export interface GuardianOfflineModel extends TravelPermitParticipantOfflineModel {
	guardianship: string;
}

export interface EscortOfflineModel extends TravelPermitParticipantOfflineModel {
	guardianship: string;
}

export interface UnderageOfflineModel extends TravelPermitParticipantOfflineModel {
	birthDate: string;
	gender: string;
}

export interface TravelPermitParticipantOfflineModel {
	name: string;
	documentNumber: string;
	documentIssuer: string;
	documentType: string;
}

export interface TravelPermitGuardianModel extends TravelPermitAdultModel {
	guardianship: LegalGuardianTypes;
	livedInBrazil?: boolean;
	lastCityInBrazil?: string;
	lastStateInBrazil?: Uf;
}

export interface TravelPermitEscortModel extends TravelPermitAdultModel {
	guardianship: LegalGuardianTypes;
}

export interface TravelPermitAdultModel extends TravelPermitParticipantModel {
	phoneNumber: string;
	email: string;
	bioId: string;
}

export interface TravelPermitUnderageModel extends TravelPermitParticipantModel {
	gender: BioGender;
	birthDate: string;
	cityOfBirth: string;
	stateOfBirth: Uf;
}

export interface TravelPermitParticipantModel {
	identifier: string;
	name: string;
	documentNumber: string;
	documentType: BioDocumentType;
	documentIssuer: string;
	issueDate: string;
	zipCode: string;
	country?: string;
	addressState: Uf;
	addressForeignStateName?: string;
	addressCity: string;
	addressForeignCityName?: string;
	neighborhood: string;
	streetAddress: string;
	addressNumber: string;
	additionalAddressInfo: string;
}

export interface TravelPermitModel {
	key?: string;
	startDate?: string;
	expirationDate: string;
	type: TravelPermitTypes;
	isRemoteTravelPermit: boolean;
	canBeHostedOnEmergency: boolean;
	requiredGuardian: TravelPermitGuardianModel;
	optionalGuardian: TravelPermitGuardianModel;
	underage: TravelPermitUnderageModel;
	escort: TravelPermitEscortModel;
}

export interface JudiciaryTravelPermitModel extends TravelPermitModel {
	judge: JudiciaryTravelPermitJudgeModel;
	authorizedByJudge: boolean;
}

export interface JudiciaryTravelPermitJudgeModel {
	name: string;
	email: string;
	identifier: string;
}

export interface TravelPermitValidationModel {
	travelPermit: TravelPermitModel;
	judiciaryTravelPermit: JudiciaryTravelPermitModel;
}
