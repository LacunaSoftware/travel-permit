import { Pipe, PipeTransform } from '@angular/core';
import { LegalGuardianTypes } from 'src/api/enums';

@Pipe({
	name: 'guardianship'
})
export class GuardianshipPipe implements PipeTransform {

	transform(value: LegalGuardianTypes | string, ...args: unknown[]): unknown {
		if (!value) {
			return 'Sem parentesco';
		}
		switch (value) {
			case LegalGuardianTypes.Father:
			case 'F':
				return 'Pai';
			case LegalGuardianTypes.Mother:
			case 'M':
				return 'Mãe';
			case LegalGuardianTypes.Guardian:
			case 'G':
				return 'Guardião';
			case LegalGuardianTypes.Tutor:
			case 'T':
				return 'Tutor';
			case LegalGuardianTypes.ThirdPartyRelated:
			case 'R':
				return "Terceiro com parentesco";
			case LegalGuardianTypes.ThirdPartyNotRelated:
			case 'S':
				return "Terceiro sem parentesco";
			default:
				return value;
		}
	}
}
