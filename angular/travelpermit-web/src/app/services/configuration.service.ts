import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { ConfigurationModel } from 'src/api/configuration';
import { environment } from 'src/environments/environment';

const apiRoute = 'api/app-configuration';

@Injectable({
	providedIn: 'root'
})
export class ConfigurationService {

	configuration = new BehaviorSubject<ConfigurationModel>({
		apiVersion: 1,
	});

	constructor(
		private http: HttpClient
	) { }

	init() {
		this.http.get<ConfigurationModel>(`${environment.cnbEndpoint}/${apiRoute}/travel-permit`)
			.subscribe(data => this.configuration.next(data));
	}
}
