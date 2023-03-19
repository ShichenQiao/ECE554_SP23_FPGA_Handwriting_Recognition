"""
Implements linear classifeirs in PyTorch.
WARNING: you SHOULD NOT use ".to()" or ".cuda()" in each implementation block.
"""
import torch
import random
import statistics
from abc import abstractmethod
from typing import Dict, List, Callable, Optional
import matplotlib.pyplot as plt
import torchvision
import numpy as np
import pickle
import time
import random


def hello_linear_classifier():
    """
    This is a sample function that we will try to import and run to ensure that
    our environment is correctly set up on Google Colab.
    """
    print("Hello from linear_classifier.py!")


class LinearClassifier:
    """An abstarct class for the linear classifiers"""
    def __init__(self):
        random.seed(0)
        torch.manual_seed(0)
        self.W = None

    def train(
        self,
        X_train: torch.Tensor,
        y_train: torch.Tensor,
        learning_rate: float = 1e-3,
        reg: float = 1e-5,
        num_iters: int = 100,
        batch_size: int = 200,
        verbose: bool = False,
    ):
        train_args = (
            self.loss,
            self.W,
            X_train,
            y_train,
            learning_rate,
            reg,
            num_iters,
            batch_size,
            verbose,
        )
        self.W, loss_history = train_linear_classifier(*train_args)
        return loss_history

    def predict(self, X: torch.Tensor):
        return predict_linear_classifier(self.W, X)

    @abstractmethod
    def loss(
        self,
        W: torch.Tensor,
        X_batch: torch.Tensor,
        y_batch: torch.Tensor,
        reg: float,
    ):
        """
        Compute the loss function and its derivative.
        Subclasses will override this.

        Inputs:
        - W: A PyTorch tensor of shape (D, C) containing (trained) weight of a model.
        - X_batch: A PyTorch tensor of shape (N, D) containing a minibatch of N
          data points; each point has dimension D.
        - y_batch: A PyTorch tensor of shape (N,) containing labels for the minibatch.
        - reg: (float) regularization strength.

        Returns: A tuple containing:
        - loss as a single float
        - gradient with respect to self.W; an tensor of the same shape as W
        """
        raise NotImplementedError

    def _loss(self, X_batch: torch.Tensor, y_batch: torch.Tensor, reg: float):
        self.loss(self.W, X_batch, y_batch, reg)

    def save(self, path: str):
        torch.save({"W": self.W}, path)
        print("Saved in {}".format(path))

    def load(self, path: str):
        W_dict = torch.load(path, map_location="cpu")
        self.W = W_dict["W"]
        if self.W is None:
            raise Exception("Failed to load your checkpoint")



class Softmax(LinearClassifier):
    """A subclass that uses the Softmax + Cross-entropy loss function"""

    def loss(
        self,
        W: torch.Tensor,
        X_batch: torch.Tensor,
        y_batch: torch.Tensor,
        reg: float,
    ):
        return softmax_loss_vectorized(W, X_batch, y_batch, reg)




def sample_batch(
    X: torch.Tensor, y: torch.Tensor, num_train: int, batch_size: int
):
    """
    Sample batch_size elements from the training data and their
    corresponding labels to use in this round of gradient descent.
    """
    X_batch = None
    y_batch = None
    indices = torch.randint(0, num_train, (batch_size, ))
    X_batch = X[indices]
    y_batch = y[indices]
    return X_batch, y_batch


def train_linear_classifier(
    loss_func: Callable,
    W: torch.Tensor,
    X: torch.Tensor,
    y: torch.Tensor,
    learning_rate: float = 1e-3,
    reg: float = 1e-5,
    num_iters: int = 100,
    batch_size: int = 200,
    verbose: bool = False,
):
    """
    Train this linear classifier using stochastic gradient descent.

    Inputs:
    - loss_func: loss function to use when training. It should take W, X, y
      and reg as input, and output a tuple of (loss, dW)
    - W: A PyTorch tensor of shape (D, C) giving the initial weights of the
      classifier. If W is None then it will be initialized here.
    - X: A PyTorch tensor of shape (N, D) containing training data; there are N
      training samples each of dimension D.
    - y: A PyTorch tensor of shape (N,) containing training labels; y[i] = c
      means that X[i] has label 0 <= c < C for C classes.
    - learning_rate: (float) learning rate for optimization.
    - reg: (float) regularization strength.
    - num_iters: (integer) number of steps to take when optimizing
    - batch_size: (integer) number of training examples to use at each step.
    - verbose: (boolean) If true, print progress during optimization.

    Returns: A tuple of:
    - W: The final value of the weight matrix and the end of optimization
    - loss_history: A list of Python scalars giving the values of the loss at each
      training iteration.
    """
    num_train, dim = X.shape
    if W is None:
        num_classes = int(torch.max(y).item()) + 1
        W = 0.000001 * torch.randn(
            dim, num_classes, device=X.device, dtype=X.dtype
        )
    else:
        num_classes = W.shape[1]
    loss_history = []
    for it in range(num_iters):
        X_batch, y_batch = sample_batch(X, y, num_train, batch_size)
        loss, grad = loss_func(W, X_batch, y_batch, reg)
        loss_history.append(loss.item())
        W -= learning_rate*grad
        if verbose and it % 100 == 0:
            print("iteration %d / %d: loss %f" % (it, num_iters, loss))

    return W, loss_history


def predict_linear_classifier(W: torch.Tensor, X: torch.Tensor):
    """
    Use the trained weights of this linear classifier to predict labels for
    data points.

    Inputs:
    - W: A PyTorch tensor of shape (D, C), containing weights of a model
    - X: A PyTorch tensor of shape (N, D) containing training data; there are N
      training samples each of dimension D.

    Returns:
    - y_pred: PyTorch int64 tensor of shape (N,) giving predicted labels for each
      elemment of X. Each element of y_pred should be between 0 and C - 1.
    """
    y_pred = torch.zeros(X.shape[0], dtype=torch.int64)
    W_t = torch.t(W)
    X_t = torch.t(X)
    S = torch.mm(W_t, X_t)
    print(S)
    _, indexes = torch.max(S, dim=0)
    y_pred = indexes
    return y_pred




def test_one_param_set(
    cls: LinearClassifier,
    data_dict: Dict[str, torch.Tensor],
    lr: float,
    reg: float,
    num_iters: int = 2000,
):
    """
    Train a single LinearClassifier instance and return the learned instance
    with train/val accuracy.

    Inputs:
    - cls (LinearClassifier): a newly-created LinearClassifier instance.
                              Train/Validation should perform over this instance
    - data_dict (dict): a dictionary that includes
                        ['X_train', 'y_train', 'X_val', 'y_val']
                        as the keys for training a classifier
    - lr (float): learning rate parameter for training a SVM instance.
    - reg (float): a regularization weight for training a SVM instance.
    - num_iters (int, optional): a number of iterations to train

    Returns:
    - cls (LinearClassifier): a trained LinearClassifier instances with
                              (['X_train', 'y_train'], lr, reg)
                              for num_iter times.
    - train_acc (float): training accuracy of the svm_model
    - val_acc (float): validation accuracy of the svm_model
    """
    train_acc = 0.0
    val_acc = 0.0
    cls.train(data_dict['X_train'], data_dict['y_train'], learning_rate=lr, reg=reg, num_iters=num_iters)
    train_acc = torch.mean((cls.predict(data_dict['X_train']) == data_dict['y_train']).float()).item()
    val_acc = torch.mean((cls.predict(data_dict['X_val']) == data_dict['y_val']).float()).item()
    return cls, train_acc, val_acc



def softmax_loss_naive(
    W: torch.Tensor, X: torch.Tensor, y: torch.Tensor, reg: float
):
    """
    Softmax loss function, naive implementation (with loops).  When you implment
    the regularization over W, please DO NOT multiply the regularization term by
    1/2 (no coefficient).

    Inputs have dimension D, there are C classes, and we operate on minibatches
    of N examples.

    Inputs:
    - W: A PyTorch tensor of shape (D, C) containing weights.
    - X: A PyTorch tensor of shape (N, D) containing a minibatch of data.
    - y: A PyTorch tensor of shape (N,) containing training labels; y[i] = c means
      that X[i] has label c, where 0 <= c < C.
    - reg: (float) regularization strength

    Returns a tuple of:
    - loss as single float
    - gradient with respect to weights W; an tensor of same shape as W
    """
    loss = 0.0
    dW = torch.zeros_like(W)
    X_t = torch.t(X)
    W_t = torch.t(W)
    S_org = torch.mm(W_t, X_t)
    max_elements, max_idxs = torch.max(S_org, dim=0)
    S_p = torch.exp(S_org - max_elements)
    for j in range(S_p.shape[1]):
      sum_s = 0.0
      for i in range(S_p.shape[0]):
        sum_s += S_p[i, j]
      for i in range(S_p.shape[0]):
        S_p[i,j] = S_p[i,j]/sum_s
      softmax = -1*torch.log(S_p[y[j], j])
      loss += softmax
    dW_t = torch.zeros_like(S_p)
    for j in range(S_p.shape[1]):
      for i in range(S_p.shape[0]):
        if i == y[j]:
          S_p[i,j] = S_p[i,j] - 1
    for i in range(S_p.shape[0]):
      for j in range(S_p.shape[1]):
        dW_t[i,j] = torch.div(S_p[i,j], S_p.shape[1])
    loss /= S_p.shape[1]
    loss += reg*(torch.sum(W**2))
    dW = torch.t(torch.mm(dW_t, X))+ reg*2*W
    return loss, dW


def softmax_loss_vectorized(
    W: torch.Tensor, X: torch.Tensor, y: torch.Tensor, reg: float
):
    """
    Softmax loss function, vectorized version.  When you implment the
    regularization over W, please DO NOT multiply the regularization term by 1/2
    (no coefficient).

    Inputs and outputs are the same as softmax_loss_naive.
    """
    loss = 0.0
    y = y.to(torch.long)
    dW = torch.zeros_like(W)
    X_t = torch.t(X)
    W_t = torch.t(W)
    S_org = torch.mm(W_t, X_t)
    max_elements, max_idxs = torch.max(S_org, dim=0)
    S_org = S_org - max_elements
    S_p = torch.exp(S_org)
    S_sum = torch.sum(S_p, dim=0)
    S_p_norm = torch.div(S_p,S_sum)
    softmax = -1*torch.log(S_p_norm[y, range(S_p.shape[1])])
    loss = torch.mean(softmax) + reg*(torch.sum(W**2))
    mask = torch.zeros_like(S_p_norm)
    mask[y, torch.arange(S_p.shape[1])] = 1
    dW_t = torch.div((S_p_norm - mask), S_p.shape[1])
    dW = torch.t(torch.mm(dW_t, X)) + reg*2*W
    return loss, dW


def softmax_get_search_params():
    """
    Return candidate hyperparameters for the Softmax model. You should provide
    at least two param for each, and total grid search combinations
    should be less than 25.

    Returns:
    - learning_rates: learning rate candidates, e.g. [1e-3, 1e-2, ...]
    - regularization_strengths: regularization strengths candidates
                                e.g. [1e0, 1e1, ...]
    """
    learning_rates = []
    regularization_strengths = []
    learning_rates = [1.15e1,1.25e1, 1.1e1, 1.2e1]
    regularization_strengths = [1.5e-5, 1.5e-6, 1e-5]
    return learning_rates, regularization_strengths


def reset_seed(number):
    """
    Reset random seed to the specific number

    Inputs:
    - number: A seed number to use
    """
    random.seed(number)
    torch.manual_seed(number)
    return
