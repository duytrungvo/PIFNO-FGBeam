import matplotlib.pyplot as plt

def plot_pred(config_data, test_x, pred_y, error_index):
    L = config_data['L']
    q = config_data['q']
    b = config_data['b']
    h = config_data['h']
    Em = config_data['Em']
    T = 100.0 * Em * h ** 3 * b / q / L ** 4
    for i in range(3):
        # key = np.random.randint(0, data_config['n_sample'])
        key = error_index[-1-i]
        x_plot = test_x[key]
        y_pred_plot = pred_y[key]

        fig = plt.figure(figsize=(10, 12))
        plt.subplot(3, 1, 1)
        plt.plot(x_plot[:, -1], x_plot[:, 0])
        plt.xlabel('$x$')
        plt.ylabel('$I$')
        plt.title(f'Input $I(x)$')
        plt.xlim([0, 1])
        # plt.ylim([0, 2])

        plt.subplot(3, 1, 2)
        plt.plot(x_plot[:, -1], y_pred_plot[:, 0], 'r', label='predict sol')
        plt.xlabel('$x$')
        plt.ylabel(r'$w$')
        # plt.ylim([0, 1])
        plt.legend()
        plt.grid(visible=True)
        plt.title(f'Predict $w(x)$')

        plt.subplot(3, 1, 3)
        plt.plot(x_plot[:, -1], y_pred_plot[:, 1], 'r', label='predict sol')
        plt.xlabel('$x$')
        plt.ylabel(r'$M$')
        # plt.ylim([0, 1])
        plt.legend()
        plt.grid(visible=True)
        plt.title(f'Predict $M(x)$')
        plt.tight_layout()

    plt.show()
