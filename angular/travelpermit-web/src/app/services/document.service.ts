import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { TravelPermitModel, TravelPermitValidationModel } from 'src/api/travel-permit';
import { environment } from 'src/environments/environment';
import { ConfigurationService } from './configuration.service';

const apiRoute = 'api/documents';

@Injectable({
	providedIn: 'root'
})
export class DocumentService {

	constructor(
		private http: HttpClient,
	) { }

	getTravelPermitInfo(key: string): Observable<TravelPermitModel> {
		return this.http.get<TravelPermitModel>(`${environment.cnbEndpoint}/api/documents/keys/${key}/travel-permit`);
	}

	getValidationModel(key: string): Observable<TravelPermitValidationModel> {
		return this.http.get<TravelPermitValidationModel>(`${environment.cnbEndpoint}/${apiRoute}/v2/keys/${key}/travel-permit`);
	}

	getDownloadTicket(key: string): Observable<{ location: string }> {
		return this.http.get<{ location: string }>(`${environment.cnbEndpoint}/${apiRoute}/keys/${key}/ticket?type=Signatures`);
	}

}
