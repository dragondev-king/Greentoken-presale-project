import { BrowserRouter, Switch, Route } from "react-router-dom";

import App from "components/app";

const Router = () => (
  <BrowserRouter>
    <Switch>
      <Route exact path="/" component={App} />
    </Switch>
  </BrowserRouter>
);

export default Router;
